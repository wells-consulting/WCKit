// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public extension String {
    static var empty: String { "\u{202F}" }

    private static var nonPrintableCharacterSet = CharacterSet.alphanumerics
        .union(CharacterSet.symbols)
        .union(CharacterSet.punctuationCharacters)
        .union(CharacterSet.whitespaces)
        .inverted

    // Form of the string to be used for searching
    var normalized: String {
        let transformed = applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower"), reverse: false)
        return transformed as String? ?? ""
    }

    // Form of the string useful for logging/display purposes
    var sanatized: String {
        components(separatedBy: String.nonPrintableCharacterSet).joined(separator: "")
            .trimmingCharacters(in: .whitespaces)
    }

    func toRegex(
        options: NSRegularExpression.Options = [.caseInsensitive]
    ) -> NSRegularExpression? {
        try? NSRegularExpression(pattern: self, options: options)
    }

    func matchesRegex(pattern: String) -> Bool {
        guard let regex = pattern.toRegex() else { return false }
        return matchesRegex(regex)
    }

    func matchesRegex(_ regex: NSRegularExpression) -> Bool {
        regex.numberOfMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: count)
        ) == 1
    }

    func matchingStrings(pattern: String) -> [[String]] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            return matching(regex: regex)
        } catch {
            return []
        }
    }

    func matching(regex: NSRegularExpression) -> [[String]] {
        let nsString = self as NSString
        let results = regex.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length)
        )
        return results.map { result in
            (0 ..< result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }

    func removing(_ regex: NSRegularExpression) -> String {
        regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: count),
            withTemplate: ""
        )
    }

    private static var emailPredicate: NSPredicate = {
        let firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegex = firstpart + "@" + serverpart + "[A-Za-z]{2,8}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex)
    }()

    func isLikelyValidEmail() -> Bool {
        String.emailPredicate.evaluate(with: self)
    }

    func urlEncoded() -> String {
        addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    }

    func removingWhitespace() -> String {
        String(
            unicodeScalars
                .filter { !NSCharacterSet.whitespacesAndNewlines.contains($0) }
                .map(Character.init)
        )
    }

    func nsRange() -> NSRange {
        NSRange(startIndex..., in: self)
    }

    func split(every length: Int) -> [Substring] {
        guard length > 0 && length < count else {
            return [suffix(from: startIndex)]
        }

        return (0 ... (count - 1) / length).map {
            dropFirst($0 * length).prefix(length)
        }
    }

    enum TruncationPosition {
        case head
        case middle
        case tail
    }

    func truncated(_ limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard count > limit else {
            return self
        }

        switch position {
        case .head:
            return leader + suffix(limit)
        case .middle:
            let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))
            let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
            return "\(prefix(headCharactersCount))\(leader)\(suffix(tailCharactersCount))"
        case .tail:
            return prefix(limit) + leader
        }
    }

    func toURL() -> URL? { URL(string: self) }

    func toDecimal() -> Decimal? {
        let text = cleanDecimalText()

        guard let decimalIndex = text.firstIndex(of: ".") else { return Decimal(string: self) }

        let lhs = String(text.prefix(upTo: decimalIndex))
        let rhs = String(text.suffix(2))

        guard let rhsFirstDigit = rhs.first, let rhsLastDigit = rhs.last else { return Decimal(string: self) }

        let decimalText = lhs + "." + String(rhsFirstDigit) + String(rhsLastDigit)
        return NSDecimalNumber(string: decimalText) as Decimal
    }

    func toInt() -> Int? { Int(sanatized) }

    func cleanDecimalText() -> String {
        do {
            let regex = try NSRegularExpression(pattern: "(\\$|,)", options: [])
            return regex.stringByReplacingMatches(
                in: self,
                options: [],
                range: NSRange(location: 0, length: count),
                withTemplate: ""
            )
        } catch {
            return self
        }
    }
}

extension NSAttributedString {
    static var nonBreakingSpace: NSAttributedString { NSAttributedString(string: "\u{202F}") }
}

// MARK: - SummaryConvertible

extension String: SummaryConvertible {
    public var summary: String? { self }
}

// MARK: Click in String

extension RangeExpression where Bound == String.Index {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}

extension StringProtocol {
    func nsRange<S: StringProtocol>(
        of string: S,
        options: String.CompareOptions = [],
        range: Range<Index>? = nil,
        locale: Locale? = nil
    ) -> NSRange? {
        self.range(
            of: string,
            options: options,
            range: range ?? startIndex ..< endIndex,
            locale: locale ?? .current
        )?.nsRange(in: self)
    }
}
