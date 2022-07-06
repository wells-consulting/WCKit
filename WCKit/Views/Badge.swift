// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import UIKit

let margin: CGFloat = 8.0

@IBDesignable
final class AppBadge: UILabel {
    var textInsets = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin) {
        didSet { invalidateIntrinsicContentSize() }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init(textInsets: UIEdgeInsets) {
        self.init(frame: CGRect.zero)
        self.textInsets = textInsets
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if text == nil {
            return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        }

        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(
            top: -textInsets.top,
            left: -textInsets.left,
            bottom: -textInsets.bottom,
            right: -textInsets.right
        )

        return textRect.inset(by: invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 8.0
        addBorder(color: backgroundColor?.darker() ?? .systemGray)
    }
}
