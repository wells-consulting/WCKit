// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import CoreData
import Foundation

public protocol ManagedObject {
    // CoreData entity name
    static var entityName: String { get }

    // CoreData id key
    static var idKeyName: String? { get }
}

public protocol PredicateConvertible {
    var predicate: NSPredicate? { get }
}

public final class PersistenceController {
    private let managedObjectContext: NSManagedObjectContext

    // MARK: Lifetime

    init(name: String) {
        ArrayValueTransformer.register()

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let persistantStoreURL = documentsURL.appendingPathComponent(name)
        let bundles = [Bundle(for: Self.self)]

        guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
            fatalError("CoreData model not found")
        }

        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
        ]

        do {
            try psc.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistantStoreURL,
                options: options
            )
        } catch {
            fatalError("Failed to add persistent store")
        }

        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }

    // MARK: Fetch

    public func fetch<T: ManagedObject>(_ objectID: Int64) -> T? {
        guard let idKeyName = T.idKeyName else { return nil }

        return fetch(matching: NSPredicate(format: "%K == %d", idKeyName, objectID))
    }

    public func fetch<T: ManagedObject>(_ uuid: UUID) -> T? {
        fetch(matching: NSPredicate(format: "%K == %@", "uuid", uuid as CVarArg))
    }

    public func fetch<T: ManagedObject>(_ fetchable: PredicateConvertible) -> T? {
        guard let predicate = fetchable.predicate else { return nil }

        return fetch(matching: predicate)
    }

    public func fetch<T: ManagedObject>(matching predicate: NSPredicate) -> T? {
        guard let object: T = materializedObject(matching: predicate) else {
            return fetch { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }

        return object
    }

    public func fetch<T: ManagedObject>(
        configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> Void = { _ in }
    ) -> [T] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)

        configurationBlock(request)

        guard let result = try? managedObjectContext.fetch(request) else {
            fatalError("Could not fetch objects")
        }

        guard let array = result as? [T] else {
            fatalError("Fetched objects have wrong type")
        }

        return array
    }

    public func makeFetchedResultsController(
        entityName: String,
        configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> Void = { _ in }
    ) -> NSFetchedResultsController<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)

        configurationBlock(request)

        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    // MARK: Create

    public func create<T: ManagedObject>() -> T {
        let coreDataObject = NSEntityDescription.insertNewObject(
            forEntityName: T.entityName,
            into: managedObjectContext
        )

        guard let object = coreDataObject as? T else {
            fatalError("Failed to create \(T.entityName)")
        }

        return object
    }

    public func materializedObject<T: ManagedObject>(matching predicate: NSPredicate) -> T? {
        for object in managedObjectContext.registeredObjects where !object.isFault {
            guard let result = object as? T else { continue }

            guard predicate.evaluate(with: result) else { continue }

            return result
        }

        return nil
    }

    // MARK: Delete

    public func delete(_ object: NSManagedObject) {
        managedObjectContext.delete(object)
    }

    // MARK: Save

    public func save() throws {
        do {
            try managedObjectContext.save()
        } catch {
            managedObjectContext.rollback()
            throw error
        }
    }
}

// MARK: - ArrayValueTransformer

@objc
final class ArrayValueTransformer: ValueTransformer {
    static func register() {
        ValueTransformer.setValueTransformer(
            ArrayValueTransformer(),
            forName: NSValueTransformerName(
                rawValue: "ArrayValueTransformer"
            )
        )
    }

    override static func transformedValueClass() -> AnyClass {
        NSArray.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? NSArray else {
            return nil
        }

        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: array,
                requiringSecureCoding: true
            )
            return data
        } catch {
            fatalError("Failed to transform `NSArray` to `Data`")
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            return nil
        }

        do {
            let array = try NSKeyedUnarchiver.unarchivedArrayOfObjects(
                ofClasses: [NSNumber.self, NSString.self],
                from: data as Data
            )
            return array
        } catch {
            fatalError("Failed to transform `Data` to `NSArray`")
        }
    }
}
