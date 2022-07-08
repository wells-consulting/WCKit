// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation
import UIKit

public enum ButtonStyle {
    case action
    case cancel
    case destructive
    case icon(UIColor, Bool)
    case plain
    case warning
}

@IBDesignable
public class AppButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        titleLabel?.textAlignment = .center
        addBorder()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.textAlignment = .center
        addBorder()
    }
}

// MARK: - Button Extensions

public extension UIButton {
    @IBInspectable internal var logTapAs: String? {
        get { accessibilityLabel }
        set { accessibilityLabel = newValue }
    }

    func setTitle(_ title: String?) {
        setTitle(title, for: UIControl.State())
    }

    func disable() {
        isEnabled = false
        let disabledForegroundColor = UIColor.systemGray2.darker() ?? .systemGray
        setTitleColor(disabledForegroundColor, for: .disabled)
        tintColor = disabledForegroundColor
        backgroundColor = .systemGray
        if layer.borderWidth > CGFloat.zero { addBorder() }
    }

    func enable(_ flag: Bool, as style: ButtonStyle? = nil) {
        if flag, let style = style {
            enable(as: style)
        } else {
            disable()
        }
    }

    func enable(as style: ButtonStyle) {
        isEnabled = true
        styleAs(style)
    }

    func styleAs(_ style: ButtonStyle) {
        switch style {
        case .action:
            tintColor = .white
            setTitleColor(.white, for: .normal)
            backgroundColor = .systemBlue
            addBorder()

        case .destructive:
            tintColor = .white
            setTitleColor(.white, for: .normal)
            backgroundColor = .systemRed

        case .cancel:
            tintColor = .black
            setTitleColor(.black, for: .normal)
            backgroundColor = .white
            addBorder()

        case let .icon(color, border):
            tintColor = color
            setTitleColor(color, for: .normal)
            backgroundColor = .clear
            if !border { removeBorder() }

        case .plain:
            tintColor = .black
            setTitleColor(.black, for: .normal)
            backgroundColor = .systemGray4
            addBorder()

        case .warning:
            tintColor = .black
            setTitleColor(.black, for: .normal)
            backgroundColor = .systemOrange
            addBorder()
        }
    }
}
