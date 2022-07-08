// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public enum DecimalFormatters {
    static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    static let currencyNumber: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    static let standard: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 1
        return formatter
    }()
}

public extension Decimal {
    init(_ value: String) {
        self = NSDecimalNumber(string: value) as Decimal
    }

    func asString() -> String {
        if let number = DecimalFormatters.number.string(from: self as NSNumber) {
            return number
        }

        let message = "\(self) cannot be converted to string"
        fatalError(message)
    }

    func asCurrency(decorate: Bool = true) -> String {
        if decorate {
            let amount = abs(self) as NSNumber
            if let money = DecimalFormatters.currency.string(from: amount) {
                return (self < Decimal.zero) ? "(" + money + ")" : money
            }
        } else if let money = DecimalFormatters.currency.string(from: self as NSNumber) {
            return money
        }

        let message = "\(self) cannot be converted to money"
        fatalError(message)
    }

    func asCurrencyNumber() -> String {
        if let money = DecimalFormatters.currencyNumber.string(from: self as NSNumber) {
            return money
        }

        let message = "\(self) cannot be converted to money"
        fatalError(message)
    }

    func asPercent() -> String {
        if let percent = DecimalFormatters.percent.string(from: self as NSNumber) {
            return percent
        }
        let message = "\(self) cannot be converted to percent"
        fatalError(message)
    }

    func rounded(_ roundingMode: NSDecimalNumber.RoundingMode, scale: Int) -> Decimal {
        let roundingBehavior = NSDecimalNumberHandler(
            roundingMode: roundingMode,
            scale: Int16(scale),
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true
        )
        return (self as NSDecimalNumber).rounding(accordingToBehavior: roundingBehavior) as Decimal
    }

    func rounded() -> Decimal {
        rounded(.plain, scale: 2)
    }

    func asIntCurrency() -> Int {
        ((self * 100.0).rounded(.bankers, scale: 2) as NSDecimalNumber).intValue
    }
}
