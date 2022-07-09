// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public extension UIImageView {
    func load(_ url: URL, placeholder: UIImage? = nil) {
        Task {
            do {
                guard let data = try await HTTP.get(url) else {
                    image = placeholder
                    return
                }
                image = UIImage(data: data)
            } catch {
                self.image = placeholder
            }
        }
    }
}
