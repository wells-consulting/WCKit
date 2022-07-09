// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public final class WCPromptLabel: UILabel {
    
    public enum Style {
        case info
        case error
        case success
        case warning

        public var symbol: WCSymbol {
            switch self {
            case .info:
                return WCSymbol(.statusInfo)
                    .palette(foregroundColor: .white, backgroundColor: .black)
            case .warning:
                return WCSymbol(.statusWarning)
                    .palette(foregroundColor: .black, backgroundColor: .systemOrange)
            case .error:
                return WCSymbol(.statusError)
                    .palette(foregroundColor: .white, backgroundColor: .systemRed)
            case .success:
                return WCSymbol(.statusSuccess)
                    .palette(foregroundColor: .black, backgroundColor: .systemGreen)
            }
        }
    }
    
    public enum Presentation {
        case `static`
        case custom(pulseDuration: Double?, onFinish: () -> Void)
        case fade
        case pulse
    }

    private var presentationTimer: Timer?

    public func clear(collapseSpace: Bool) {
        presentationTimer?.invalidate()
        presentationTimer = nil

        layer.removeAllAnimations()

        if collapseSpace {
            text = nil
            attributedText = nil
            isHidden = true
        } else {
            text = nil
            attributedText = .nonBreakingSpace
            isHidden = false
        }
    }

    public func success(_ text: String, presentation: Presentation = .static) {
        setText(text, style: .success, presentation: presentation)
    }

    public func info(_ text: String, presentation: Presentation = .static) {
        setText(text, style: .info, presentation: presentation)
    }

    public func warning(_ text: String, presentation: Presentation = .static) {
        setText(text, style: .warning, presentation: presentation)
    }

    public func error(_ error: Error, presentation: Presentation = .static) {
        setText(error.localizedDescription, style: .error, presentation: presentation)
    }

    public func error(_ text: String, presentation: Presentation = .static) {
        setText(text, style: .error, presentation: presentation)
    }

    public func setText(_ text: String, style: Style, presentation: Presentation = .static) {
        layer.removeAllAnimations()

        isHidden = false

        let builder = AttributedStringBuilder(font: font)

        builder.appendSymbol(style.symbol)
        builder.appendSpacer(count: 2)

        builder.appendText(
            text,
            color: textColor,
            alignment: textAlignment
        )

        attributedText = builder.buildAttributedString()

        present(presentation)
    }

    private func stopPresentationTimer() {
        presentationTimer?.invalidate()
        presentationTimer = nil
    }

    private func present(_ presentation: Presentation) {
        if case .static = presentation { return }

        if let timer = presentationTimer {
            timer.invalidate()
            presentationTimer = nil
        }

        presentationTimer = Timer.scheduledTimer(
            timeInterval: Double(1),
            target: self,
            selector: #selector(presentationTimerElapsed(_:)),
            userInfo: presentation,
            repeats: false
        )
    }

    private func animate(duration: Double, repeatCount: Float, autoReverse: Bool) {
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.duration = duration
        fade.fromValue = NSNumber(value: 0.0)
        fade.toValue = NSNumber(value: 1.0)
        fade.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        fade.autoreverses = autoReverse
        fade.repeatCount = repeatCount
        layer.add(fade, forKey: "opacity")
    }

    @objc
    private func presentationTimerElapsed(_ timer: Timer) {
        let userInfo = timer.userInfo

        presentationTimer = nil

        guard let presentation = userInfo as? Presentation else { return }

        var timeInteveral = 3.0

        switch presentation {
        case .static: // This is an invalid state
            return

        case .fade:
            animate(duration: 3.0, repeatCount: 0, autoReverse: false)

        case .pulse:
            animate(duration: 1.0, repeatCount: Float.infinity, autoReverse: true)

        case let .custom(duration, _):
            if let value = duration { timeInteveral = value }
            animate(duration: 1.0, repeatCount: Float.infinity, autoReverse: true)
        }

        Timer.scheduledTimer(
            timeInterval: timeInteveral,
            target: self,
            selector: #selector(pulseLabelCompleted(_:)),
            userInfo: presentation,
            repeats: false
        )
    }

    @objc
    private func pulseLabelCompleted(_ timer: Timer) {
        let userInfo = timer.userInfo

        timer.invalidate()

        guard let presentation = userInfo as? Presentation else { return }

        switch presentation {
        case .fade, .static:
            break

        case .pulse:
            DispatchQueue.main.async { self.layer.removeAllAnimations() }

        case let .custom(_, action):
            DispatchQueue.main.async { action() }
        }
    }

    public func addButtonRecognizer(target: UIView, action: Selector, actionName: String) {
        isUserInteractionEnabled = true
        let labelGR = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(labelGR)
        labelGR.name = actionName
    }

    public func addButtonRecognizer(target: UIViewController, action: Selector, actionName: String) {
        isUserInteractionEnabled = true
        let labelGR = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(labelGR)
        labelGR.name = actionName
    }

    public func boundingRect(forCharacterRange range: NSRange) -> CGRect? {
        guard let attributedText = attributedText else { return nil }

        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)

        var glyphRange = NSRange()
        // Convert the range for glyphs.
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)

        var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        rect.origin.y += 16 // move down a bit to show popup under the tap point
        return rect
    }

    // support detecting tap location
    public func indexOfLetterAtPoint(point: CGPoint) -> Int? {
        guard let attributedText = attributedText else { return nil }
        let textContainer = NSTextContainer(size: frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }

    public func hide(_ flag: Bool = true) { isHidden = flag }

    public func show() { isHidden = false }
}

// MARK: -

extension UILabel {
    func setNonBreakingText(_ text: String?) {
        if let text = text {
            self.text = !text.isEmpty ? text : .empty
        } else {
            self.text = .empty
        }
    }

    func setFieldValue(_ value: String?, label: UILabel) {
        guard let value = value, !value.isEmpty else {
            label.isHidden = true
            text = nil
            isHidden = true
            return
        }

        label.isHidden = false
        text = value
        isHidden = false
    }
}
