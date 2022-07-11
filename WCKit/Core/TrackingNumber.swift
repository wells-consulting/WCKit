// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

enum TrackingNumberType: String, Codable {
    case ups
    case upsSurePost
    case usps
    case fedex
    case fedexSmartPost
    case c2sLTL
    case lso
}

struct TrackingNumber: CustomStringConvertible, Codable {
    let type: TrackingNumberType
    let encodedText: String
    let text: String
    let symbology: Symbology?

    var description: String {
        if let symbology = symbology {
            return "'\(text)' [\(type.rawValue) - \(symbology.rawValue)]"
        }
        return "'\(text)' [\(type.rawValue)]"
    }

    //

    init?(barcode: Barcode) {
        switch barcode.symbology {
        case .datamatrix:
            return nil // Decode whatever types of datamatrix

        case .code128, .ean128:
            guard let trackingNumber = TrackingNumber.parse(
                barcode.text,
                symbology: barcode.symbology
            ) else {
                return nil
            }
            self = trackingNumber

        default:
            return nil
        }
    }

    private init(
        type: TrackingNumberType,
        encodedText: String,
        text: String,
        symbology: Symbology?
    ) {
        self.type = type
        self.encodedText = encodedText
        self.text = text
        self.symbology = symbology
    }

    static func parsable(_ text: String) -> Bool {
        TrackingNumber.parse(text, symbology: nil) != nil
    }

    static func parse(_ rawText: String, symbology: Symbology?) -> TrackingNumber? {
        // A bit funky, but this removes all non-alphanumeric characters from the string
        let text = rawText
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: "")

        let range = NSRange(location: 0, length: text.count)

        // UPSd
        if text.matchesRegex(pattern: "^1Z[0-9A-Z]{16}$") {
            return TrackingNumber(
                type: .ups,
                encodedText: rawText,
                text: text,
                symbology: symbology
            )
        }

        // UPS SurePost

        if
            let regex = "^(420[0-9]{5})?92([0-9]{24})$".toRegex(),
            let match = regex.firstMatch(in: text, options: [], range: range),
            match.numberOfRanges == 3
        {
            return TrackingNumber(
                type: .upsSurePost,
                encodedText: rawText,
                text: (text as NSString).substring(with: match.range(at: 2)),
                symbology: symbology
            )
        }

        // USPS

        if
            let regex = "^(420[0-9]{5})?(9[234]0[0-9]{19})$".toRegex(),
            let match = regex.firstMatch(in: text, options: [], range: range),
            match.numberOfRanges == 3
        {
            return TrackingNumber(
                type: .usps,
                encodedText: rawText,
                text: (text as NSString).substring(with: match.range(at: 2)),
                symbology: symbology
            )
        }

        // FedEx 20-digit

        if text.matchesRegex(pattern: "^[0-9]{20}$") {
            return TrackingNumber(
                type: .fedex,
                encodedText: rawText,
                text: text,
                symbology: symbology
            )
        }

        // FedEx 12-digit

        if
            let regex = "^([0-9]{22})?([0-9]{12})$".toRegex(),
            let match = regex.firstMatch(in: text, options: [], range: range),
            match.numberOfRanges == 3
        {
            return TrackingNumber(
                type: .fedex,
                encodedText: rawText,
                text: (text as NSString).substring(with: match.range(at: 2)),
                symbology: symbology
            )
        }

        // FedEx SmartPost

        if
            let regex = "^(420[0-9]{5})?92([0-9]{20})$".toRegex(),
            let match = regex.firstMatch(in: text, options: [], range: range),
            match.numberOfRanges == 3
        {
            return TrackingNumber(
                type: .fedexSmartPost,
                encodedText: rawText,
                text: (text as NSString).substring(with: match.range(at: 2)),
                symbology: symbology
            )
        }

        // Out of ideas here
        return nil
    }
}
