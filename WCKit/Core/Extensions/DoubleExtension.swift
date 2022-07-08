// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public enum DoubleFormatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()

    static let currencyNumber: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
}

public extension Double {
    func asCurrency(includeCurrencySymbol: Bool = true) -> String {
        if includeCurrencySymbol, let money = DoubleFormatters.currency.string(from: self as NSNumber) {
            return money
        }
        if let money = DoubleFormatters.currencyNumber.string(from: self as NSNumber) {
            return money
        }
        let message = "\(self) cannot be converted to money"
        fatalError(message)
    }

    func asPercent() -> String {
        if let percent = DoubleFormatters.percent.string(from: self as NSNumber) {
            return percent
        }
        let message = "\(self) cannot be converted to percent"
        fatalError(message)
    }

    func asNumber(maximumFractionDigits: Int = 2) -> String {
        let formatter = DoubleFormatters.number
        formatter.maximumFractionDigits = maximumFractionDigits

        if let number = formatter.string(from: self as NSNumber) {
            return number
        }

        let message = "\(self) cannot be converted to number"
        fatalError(message)
    }
}
