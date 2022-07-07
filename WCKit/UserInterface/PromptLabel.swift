// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public enum PromptType {
    case info
    case error
    case success
    case warning

    var symbol: Symbol {
        switch self {
        case .info:
            return Symbol(.statusInfo)
                .palette(foregroundColor: .white, backgroundColor: .black)
        case .warning:
            return Symbol(.statusWarning)
                .palette(foregroundColor: .black, backgroundColor: .systemOrange)
        case .error:
            return Symbol(.statusError)
                .palette(foregroundColor: .white, backgroundColor: .systemRed)
        case .success:
            return Symbol(.statusSuccess)
                .palette(foregroundColor: .black, backgroundColor: .systemGreen)
        }
    }
}

public final class PromptLabel: UILabel {
    enum Presentation {
        case `static`
        case custom(pulseDuration: Double?, onFinish: () -> Void)
        case fade
        case pulse
    }

    private var presentationTimer: Timer?

    func clear(collapseSpace: Bool) {
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

    func success(_ text: String, presentation: Presentation = .static) {
        setText(text, type: .success, presentation: presentation)
    }

    func info(_ text: String, presentation: Presentation = .static) {
        setText(text, type: .info, presentation: presentation)
    }

    func warning(_ text: String, presentation: Presentation = .static) {
        setText(text, type: .warning, presentation: presentation)
    }

    func error(_ error: Error, presentation: Presentation = .static) {
        setText(error.localizedDescription, type: .error, presentation: presentation)
    }

    func error(_ text: String, presentation: Presentation = .static) {
        setText(text, type: .error, presentation: presentation)
    }

    func setText(_ text: String, type: PromptType, presentation: Presentation = .static) {
        layer.removeAllAnimations()

        isHidden = false

        let builder = AttributedStringBuilder(font: font)

        builder.appendSymbol(type.symbol)
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

    func addButtonRecognizer(target: UIView, action: Selector, actionName: String) {
        isUserInteractionEnabled = true
        let labelGR = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(labelGR)
        labelGR.name = actionName
    }

    func addButtonRecognizer(target: UIViewController, action: Selector, actionName: String) {
        isUserInteractionEnabled = true
        let labelGR = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(labelGR)
        labelGR.name = actionName
    }

    func boundingRect(forCharacterRange range: NSRange) -> CGRect? {
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
    func indexOfLetterAtPoint(point: CGPoint) -> Int? {
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

    func hide(_ flag: Bool = true) { isHidden = flag }

    func show() { isHidden = false }
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
