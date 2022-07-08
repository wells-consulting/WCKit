// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public struct JSONError: LocalizedError {
    public let message: String
    public let jsonText: String?

    public var errorDescription: String? { message }

    init(message: String, data: Data? = nil) {
        self.message = message
        if let data = data, let jsonText = String(data: data, encoding: .utf8) {
            self.jsonText = jsonText
        } else {
            jsonText = nil
        }
    }
}

public enum JSON {
    public static func stringify<T: Encodable>(_ value: T) -> String? {
        do {
            let data = try encoder.encode(value)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    // MARK: Decoding

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            var string = try container.decode(String.self)
            if let date = Date(iso8601String: string) {
                return date
            }
            throw JSONError(message: "Invalid date format for '\(string)'")
        }
        return decoder
    }()

    public static func decode<T: Decodable>(_ data: Data) throws -> T {
        var message = ""

        func pathToDecodingContext(_ context: DecodingError.Context) -> String {
            var path = [String]()
            for key in context.codingPath { path.append(key.stringValue) }
            return path.joined(separator: ".")
        }

        do {
            let object: T = try decoder.decode(T.self, from: data)
            return object
        } catch let DecodingError.dataCorrupted(context) {
            let path = pathToDecodingContext(context)
            message = "\(T.self): data corrupted. Issue decoding '\(path)': " + context.debugDescription
        } catch let DecodingError.keyNotFound(key, context) {
            let path = pathToDecodingContext(context)
            if path.isEmpty {
                message = "\(T.self): key '\(key.stringValue)' missing (KeyNotFound)"
            } else {
                message = "\(T.self): key '\(key.stringValue)' missing at '\(path)' (KeyNotFound)"
            }
        } catch let DecodingError.valueNotFound(type, context) {
            let path = pathToDecodingContext(context)
            if path.isEmpty {
                message = "\(T.self): value \(type) not found (ValueNotFound)"
            } else {
                message = "\(T.self): value \(type) not found at '\(path)' (ValueNotFound)"
            }
        } catch let DecodingError.typeMismatch(type, context) {
            let path = pathToDecodingContext(context)
            if path.isEmpty {
                message = "\(T.self): \(type) not found (TypeMismatch)"
            } else {
                message = "\(T.self): \(type) not found at '\(path)' (TypeMismatch)"
            }
        } catch {
            message = "\(T.self): " + error.localizedDescription
        }

        if let string = String(data: data, encoding: .utf8) {
            let truncatedString = string.prefix(min(string.count, 100))
            message.append("\n\(truncatedString)")
        }

        throw JSONError(message: message, data: data)
    }

    // MARK: Encoding

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    public static func encode<T: Encodable>(_ value: T) throws -> Data {
        
        func pathToEncodingContext(_ context: EncodingError.Context) -> String {
            var path = [String]()
            for key in context.codingPath {
                path.append(key.stringValue)
            }
            return path.joined(separator: ".")
        }
        
        do {
            return try encoder.encode(value)
        } catch let EncodingError.invalidValue(key, context) {
            let path = pathToEncodingContext(context)
            throw JSONError(message: "\(T.self): key '\(key)' is missing for path '\(path)'")
        } catch {
            throw JSONError(message: "\(T.self): " + error.localizedDescription)
        }
    }
}

// MARK: -

public extension JSONSerialization {
    static func decode(_ data: Data) -> [String: Any]? {
        guard let value = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        return value as? [String: Any]
    }
}

// MARK: -

public enum JSONValue {
    indirect case array([JSONValue])
    case bool(Bool)
    case date(Date)
    case decimal(Decimal)
    case double(Double)
    case int(Int)
    case int64(Int64)
    case null
    indirect case object([String: JSONValue])
    case string(String)

    public subscript(index: Int) -> JSONValue? {
        guard case let .array(array) = self else { return nil }
        return array[index]
    }

    public subscript(key: String) -> JSONValue? {
        guard case let .object(dictionary) = self else { return nil }
        return dictionary[key]
    }
}

extension JSONValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            if let date = Date(iso8601String: value) {
                self = .date(date)
            } else {
                self = .string(value)
            }
            return
        }

        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
            return
        }

        if let value = try? container.decode(Int.self) {
            self = .int(value)
            return
        }

        if let value = try? container.decode(Double.self) {
            if value.rounded(.down) == value, let int64Value = try? container.decode(Int64.self) {
                self = .int64(int64Value)
            } else {
                self = .double(value)
            }
            return
        }

        if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
            return
        }

        if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
            return
        }

        if container.decodeNil() {
            self = .null
            return
        }

        if let value = try? container.decode(Decimal.self) {
            self = .decimal(value)
            return
        }

        throw DecodingError.dataCorrupted(
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Cannot decode value of type of JSON"
            )
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .array(value):
            try container.encode(value)

        case let .bool(value):
            try container.encode(value)

        case let .date(value):
            try container.encode(value)

        case let .decimal(value):
            try container.encode(value)

        case let .double(value):
            try container.encode(value)

        case let .int(value):
            try container.encode(value)

        case let .int64(value):
            try container.encode(value)

        case .null:
            try container.encodeNil()

        case let .object(value):
            try container.encode(value)

        case let .string(value):
            try container.encode(value)
        }
    }
}

// MARK: - Accessors

public extension JSONValue {
    var int: Int? {
        guard case let .int(value) = self else { return nil }
        return value
    }

    var int64: Int64? {
        guard case let .int64(value) = self else { return nil }
        return value
    }

    var decimal: Decimal? {
        guard case let .decimal(value) = self else { return nil }
        return value
    }

    var double: Double? {
        guard case let .double(value) = self else { return nil }
        return value
    }

    var string: String? {
        guard case let .string(value) = self else { return nil }
        return value
    }

    var isNil: Bool {
        guard case .null = self else { return false }
        return true
    }

    var bool: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        guard case let .bool(value) = self else { return nil }
        return value
    }

    var array: [JSONValue]? {
        guard case let .array(value) = self else { return nil }
        return value
    }

    var object: [String: JSONValue]? {
        guard case let .object(value) = self else { return nil }
        return value
    }
}
