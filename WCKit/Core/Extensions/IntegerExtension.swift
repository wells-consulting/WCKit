// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public enum IntFormatters {
    static let byteCount = ByteCountFormatter()

    static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

    static let count: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        return formatter
    }()

    static let duration: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter
    }()
}

public extension Int {
    func asCount() -> String {
        if let count = IntFormatters.count.string(from: self as NSNumber) {
            return count
        }
        fatalError("\(self) cannot be converted to count")
    }

    func asByteCount() -> String {
        IntFormatters.byteCount.string(fromByteCount: Int64(self))
    }

    func asDuration() -> String {
        if let string = IntFormatters.duration.string(from: TimeInterval(self)) {
            return string
        }
        fatalError("\(self) cannot bed converted to duration")
    }

    func asDecimalCurrency() -> Decimal {
        Decimal(Double(self) / 100.0)
    }
}

public extension Int32 {
    func asCount() -> String {
        if let count = IntFormatters.count.string(from: self as NSNumber) {
            return count
        }
        fatalError("\(self) cannot be converted to count")
    }

    func asByteCount() -> String {
        IntFormatters.byteCount.string(fromByteCount: Int64(self))
    }

    func asDuration() -> String {
        if let string = IntFormatters.duration.string(from: TimeInterval(self)) {
            return string
        }
        fatalError("\(self) cannot bed converted to duration")
    }

    func asDecimalCurrency() -> Decimal {
        Decimal(Double(self) / 100.0)
    }
}

public extension Int64 {
    func asCount() -> String {
        if let count = IntFormatters.count.string(from: self as NSNumber) {
            return count
        }
        fatalError("\(self) cannot be converted to count")
    }

    func asByteCount() -> String {
        IntFormatters.byteCount.string(fromByteCount: self)
    }

    func asDuration() -> String {
        if let string = IntFormatters.duration.string(from: TimeInterval(self)) {
            return string
        }
        fatalError("\(self) cannot bed converted to duration")
    }

    func asDecimalCurrency() -> Decimal {
        Decimal(Double(self) / 100.0)
    }
}

public extension UInt {
    func asCount() -> String {
        if let count = IntFormatters.count.string(from: self as NSNumber) {
            return count
        }
        fatalError("\(self) cannot be converted to count")
    }

    func asByteCount() -> String {
        IntFormatters.byteCount.string(fromByteCount: Int64(self))
    }

    func asDuration() -> String {
        if let string = IntFormatters.duration.string(from: TimeInterval(self)) {
            return string
        }
        fatalError("\(self) cannot bed converted to duration")
    }

    func asDecimalCurrency() -> Decimal {
        Decimal(Double(self) / 100.0)
    }
}
