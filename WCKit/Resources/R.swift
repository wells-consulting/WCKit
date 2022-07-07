// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

enum R {
    enum fonts {
        static let title: UIFont = {
            let size: CGFloat = Runtime.isPhone ? 24.0 : 32.0
            return UIFont.systemFont(ofSize: size, weight: .heavy)
        }()

        static let subtitle: UIFont = {
            let size: CGFloat = Runtime.isPhone ? 24.0 : 28.0
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }()

        static let body: UIFont = {
            let size: CGFloat = 24.0
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        }()

        static let menubar: UIFont = {
            let size: CGFloat = 24.0
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }()

        static let button: UIFont = {
            let size: CGFloat = 24.0
            return UIFont.systemFont(ofSize: size, weight: .heavy)
        }()

        static let symbol: UIFont = {
            let size: CGFloat = 24.0
            return UIFont.systemFont(ofSize: size, weight: .heavy)
        }()

        static let caption: UIFont = {
            let size: CGFloat = 14.0
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        }()
    }
}
