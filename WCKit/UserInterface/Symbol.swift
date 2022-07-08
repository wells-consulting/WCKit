// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation
import UIKit

public final class Symbol {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    convenience init(_ name: Name) {
        self.init(nameString: name.rawValue)
    }

    private static func cleanupName(_ name: String) -> String {
        guard let regex = "_[A-Za-z]+\\.".toRegex() else { return name }
        return name.removing(regex)
    }

    private init(nameString: String) {
        name = Symbol.cleanupName(nameString)

        if name.hasPrefix("status"), let symbolName = Symbol.Name(rawValue: name) {
            switch symbolName {
            case .statusAdded:
                palette(foregroundColor: .black, backgroundColor: .systemGreen)
            case .statusError:
                palette(foregroundColor: .white, backgroundColor: .systemRed)
            case .statusFinished:
                palette(foregroundColor: .white, backgroundColor: .systemBlue)
            case .statusInfo:
                palette(foregroundColor: .white, backgroundColor: .systemBlue)
            case .statusSuccess:
                palette(foregroundColor: .black, backgroundColor: .systemGreen)
            case .statusUnknown:
                palette(foregroundColor: .white, backgroundColor: .black)
            case .statusWarning:
                palette(foregroundColor: .systemOrange, backgroundColor: .black)
            default:
                break
            }
        }
    }

    private var sizeConfiguration: UIImage.SymbolConfiguration?
    private var colorConfiguration: UIImage.SymbolConfiguration?

    public var image: UIImage? {
        if
            let colorConfiguration = colorConfiguration,
            let sizeConfiguration = sizeConfiguration
        {
            let configuration = colorConfiguration.applying(sizeConfiguration)
            return UIImage(systemName: name, withConfiguration: configuration)
        }

        if let colorConfiguration = colorConfiguration {
            return UIImage(systemName: name, withConfiguration: colorConfiguration)
        }

        let defaultColorConfiguration = UIImage.SymbolConfiguration(
            hierarchicalColor: .systemGray4
        )

        if let sizeConfiguration = sizeConfiguration {
            let configuration = defaultColorConfiguration.applying(sizeConfiguration)
            return UIImage(systemName: name, withConfiguration: configuration)
        }

        return UIImage(systemName: name, withConfiguration: defaultColorConfiguration)
    }

    // MARK: Size

    public func font(_ font: UIFont) -> Symbol {
        sizeConfiguration = UIImage.SymbolConfiguration(font: font, scale: .large)
        return self
    }

    // MARK: Color

    @discardableResult
    public func color(_ color: UIColor) -> Symbol {
        colorConfiguration = UIImage.SymbolConfiguration(hierarchicalColor: color)
        return self
    }

    @discardableResult
    public func autoTint(basedOn color: UIColor) -> Symbol {
        colorConfiguration = UIImage.SymbolConfiguration(hierarchicalColor: color)
        return self
    }

    @discardableResult
    public func palette(foregroundColor: UIColor, backgroundColor: UIColor) -> Symbol {
        colorConfiguration = UIImage.SymbolConfiguration(
            paletteColors: [foregroundColor, backgroundColor]
        )
        return self
    }
}

public extension Symbol {
    enum Name: String, CaseIterable {
        // MARK: Objects

        case banknote = "_object.banknote.fill"
        case barcodeScanner = "barcode.viewfinder"
        case bicycle
        case bin = "arrow.up.bin.fill"
        case cameraScanner = "camera.viewfinder"
        case cashDrawer = "tray.fill"
        case console = "desktopcomputer"
        case container = "rectangle.stack.fill"
        case creditCard = "creditcard.fill"
        case dashboard = "chart.bar.fill"
        case database = "macpro.gen2"
        case developer = "person.icloud.fill"
        case document = "doc.plaintext.fill"
        case folder = "folder.fill"
        case item = "tag.fill"
        case makeDocument = "doc.fill.badge.plus"
        case map = "map.fill"
        case menubarIndicator = "arrow.forward.square.fill"
        case order = "bag.badge.plus"
        case package = "shippingbox.fill"
        case pallet = "square.stack.3d.up"
        case person = "person.fill"
        case photo = "photo.fill"
        case printer = "printer.fill"
        case purchaseOrder = "list.bullet"
        case receipt = "doc.text"
        case recent = "calendar.badge.clock"
        case serialize = "link"
        case session = "person.badge.clock"
        case taskList = "list.number"
        case today = "clock.fill"
        case utilities = "folder.badge.gearshape"
        case website = "network"
        case willcallOrder = "figure.walk"
        case workforce = "person.3.fill"

        // MARK: Actions

        case add = "plus.square"
        case build = "hammer.fill"
        case clear = "xmark.circle"
        case connect = "cable.connector.horizontal"
        case debug = "ant.fill"
        case delete = "trash"
        case edit = "pencil.circle.fill"
        case hidePassword = "eye.slash"
        case inspect = "binoculars.fill"
        case move = "arrow.triangle.branch"
        case reload = "arrow.triangle.2.circlepath.circle"
        case remove = "multiply.square"
        case search = "magnifyingglass"
        case showPassword = "eye"
        case signOut = "figure.wave"
        case sort = "arrow.up.arrow.down.square"
        case undo = "arrow.uturn.backward.square"
        case unlock = "lock.open.fill"
        case void = "trash.square"

        // MARK: Status (Filled Circles)

        case statusAdded = "plus.circle.fill"
        case statusError = "multiply.circle.fill"
        case statusFinished = "hand.thumbsup.circle.fill"
        case statusInfo = "info.circle.fill"
        case statusSuccess = "checkmark.circle.fill"
        case statusUnknown = "questionmark.circle.fill"
        case statusWarning = "exclamationmark.circle.fill"

        // MARK: Checkbox

        case checkboxChecked = "checkmark.square"
        case checkboxUnchecked = "square"

        // MARK: Marks

        case bookmark = "bookmark.fill"
        case checkmark
        case chevronDown = "chevron.down"
        case chevronLeft = "chevron.left"
        case chevronRight = "chevron.right"
        case chevronUp = "chevron.up"
        case chevronUpDown = "chevron.up.chevron.down"
        case exclamationMark = "exclamationmark"
        case exclamationMark2 = "exclamationmark.2"
        case exclamationMark3 = "exclamationmark.3"
        case infoMark = "info"
        case questionMark = "questionmark"
        case warning = "exclamationmark.triangle"
        case xmark
    }
}

// MARK: -

extension UIButton {
    // NOTE: Buttons are auto-styled

    func setSymbol(name: Symbol.Name, font: UIFont) {
        let image = Symbol(name)
            .palette(
                foregroundColor: titleColor(for: .normal) ?? UIColor.black,
                backgroundColor: backgroundColor ?? UIColor.white
            )
            .font(font)
            .image

        setImage(image, for: UIControl.State())
    }
}

// MARK: -

extension UIImageView {
    func checkbox(isChecked: Bool) {
        let symbol = Symbol(isChecked ? .checkboxChecked : .checkboxUnchecked)
            .palette(foregroundColor: .systemBlue, backgroundColor: .black)
        image = symbol.image
    }
}
