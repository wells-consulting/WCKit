// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

enum Symbology: String, Codable {
    case invalid
    case code39
//    case codabar
    case code128
//    case d2Of5
//    case iata
//    case i2Of5
//    case code93
    case upca
//    case upce0
//    case ean8
//    case ean13
//    case code11
//    case code49
//    case msi
    case ean128
//    case upce1
//    case pdf417
//    case code16k
//    case c39Full
//    case upcd
//    case trioptic
//    case bookland
//    case coupon
//    case nw7
//    case isbt128
//    case microPDF
    case datamatrix
//    case qrCode
//    case microPDFCCA
//    case postnetUS
//    case planetCode
//    case code32
//    case isbt128Con
//    case jpPostal
//    case auPostal
//    case nlPostal
//    case maxicode
//    case caPostal
//    case ukPostal
//    case macroPDF
//    case rss14
//    case rssLimited
//    case rssExpanded
//    case scanlet
//    case upca2
//    case upce0V2
//    case ean8V2
//    case ean13V2
//    case upce1V2
//    case ccaEAN128
//    case ccaEAN13
//    case ccaEAN8
//    case ccaRSSExpanded
//    case ccaRSSLimited
//    case ccaRSS14
//    case ccaUPCA
//    case ccaUPCE
//    case cccEAN128
//    case tlc39
//    case ccbEAN128
//    case ccbEAN13
//    case ccbEAN8
//    case ccbRSSExpanded
//    case ccbRSSLimited
//    case ccbRSS14
//    case ccbUPCA
//    case ccbUPCE
//    case signatureCapture
//    case matrix2Of5
//    case cn2Of5
//    case upcaV5
//    case upce0V5
//    case ean8V5
//    case ean13V5
//    case upce1V5
//    case macroMicroPDF
//    case microQR
//    case aztec
//    case hanxin
//    case kr3Of5
//    case issn
//    case matrix2Of5V2
//    case aztecRuneCode
//    case newCouponCode
}

// MARK: -

struct Barcode: Codable {
    let symbology: Symbology
    let text: String

    init(symbology: Symbology, text: String) {
        self.symbology = symbology
        self.text = text.removingWhitespace()
    }

    var description: String {
        "\(text) (\(symbology.rawValue))"
    }
}
