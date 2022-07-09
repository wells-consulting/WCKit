// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

private protocol AttributedStringPart {
    func add(to buffer: NSMutableAttributedString)
}

public class AttributedStringBuilder {
    private struct SymbolPart: AttributedStringPart {
        let font: UIFont
        let symbol: WCSymbol

        func add(to buffer: NSMutableAttributedString) {
            guard let image = symbol.font(font).image else {
                buffer.append(NSAttributedString(string: "[symbol:" + symbol.name + "]"))
                return
            }

            let string = NSMutableAttributedString(attachment: NSTextAttachment(image: image))
            string.addAttributes([.font: font], range: NSRange(location: 0, length: 1))

            buffer.append(string)
        }
    }

    private struct TextPart: AttributedStringPart {
        let text: String
        let font: UIFont
        let color: UIColor
        let alignment: NSTextAlignment?

        func add(to buffer: NSMutableAttributedString) {
            var attributes = [NSAttributedString.Key: Any]()

            attributes[.font] = font
            attributes[.foregroundColor] = color

            if let alignment = alignment {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = alignment
                attributes[.paragraphStyle] = paragraphStyle
            }

            let string = NSAttributedString(string: text, attributes: attributes)
            buffer.append(string)
        }
    }

    private struct SpacerPart: AttributedStringPart {
        let font: UIFont
        let count: Int

        func add(to buffer: NSMutableAttributedString) {
            let string = NSAttributedString(string: String(repeating: " ", count: count), attributes: [.font: font])
            buffer.append(string)
        }
    }

    private struct LinefeedPart: AttributedStringPart {
        let font: UIFont
        let count: Int

        func add(to buffer: NSMutableAttributedString) {
            let string = NSAttributedString(string: String(repeating: "\n", count: count), attributes: [.font: font])
            buffer.append(string)
        }
    }

    private var font: UIFont
    private var parts = [AttributedStringPart]()

    init(font: UIFont) {
        self.font = font
    }

    public func appendLinefeed(count: Int = 1) {
        parts.append(LinefeedPart(font: font, count: count))
    }

    public func appendText(_ text: String, color: UIColor, alignment: NSTextAlignment? = nil) {
        parts.append(TextPart(text: text, font: font, color: color, alignment: alignment))
    }

    public func appendSpacer(count: Int = 1) {
        parts.append(SpacerPart(font: font, count: count))
    }

    public func appendSymbol(_ symbol: WCSymbol) {
        parts.append(SymbolPart(font: font, symbol: symbol))
    }

    public func buildAttributedString() -> NSAttributedString {
        let buffer = NSMutableAttributedString()

        buffer.insert(NSAttributedString(string: "\u{200b}"), at: 0)

        for part in parts { part.add(to: buffer) }

        return buffer
    }
}
