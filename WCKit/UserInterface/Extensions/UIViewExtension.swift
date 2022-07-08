// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation
import UIKit

public extension UIView {
    func addBorder() {
        addBorder(color: backgroundColor?.darker() ?? .systemGray)
    }

    func addBorder(color: UIColor) {
        layer.borderWidth = 1.5
        layer.borderColor = color.cgColor
    }

    func removeBorder() {
        layer.borderWidth = 0.0
        layer.borderColor = nil
    }
}
