// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00ff00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000ff) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    func lighter(byPercent percent: CGFloat = 30.0) -> UIColor? {
        adjust(byPercent: abs(percent))
    }

    func darker(byPercent percent: CGFloat = 30.0) -> UIColor? {
        adjust(byPercent: -1 * abs(percent))
    }

    func adjust(byPercent percent: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(
                red: min(red + percent / 100, 1.0),
                green: min(green + percent / 100, 1.0),
                blue: min(blue + percent / 100, 1.0),
                alpha: alpha
            )
        } else {
            return nil
        }
    }
}
