// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public extension UIImage {
    func resized(to width: Double) -> UIImage? {
        let ar = size.height / size.width
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: CGSize(width: width, height: width * ar)))
        }
    }

    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    convenience init?(barcode: String) {
        let data = barcode.data(using: .ascii)

        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")

        guard let ciImage = filter.outputImage else {
            return nil
        }

        self.init(ciImage: ciImage)
    }
}
