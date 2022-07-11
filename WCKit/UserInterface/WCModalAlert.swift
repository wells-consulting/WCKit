// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public final class WCModalAlert: UIView {
    private let instance: Instance

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    init(
        title: String,
        message: String,
        severity: WCAlert.Severity = .info,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        instance = Instance(
            title: title,
            message: message,
            severity: severity,
            function: function,
            file: file,
            line: line
        )
        super.init(frame: CGRect.zero)
    }

    init(title: String, error: Error) {
        instance = Instance(
            title: title,
            message: error.localizedDescription,
            severity: .error,
            function: #function,
            file: #file,
            line: #line
        )
        super.init(frame: CGRect.zero)
    }

    static func show(
        title: String,
        message: String,
        severity: WCAlert.Severity = .info,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let alertView = Instance(
            title: title,
            message: message,
            severity: severity,
            function: function,
            file: file,
            line: line
        )
        alertView.show()
    }

    static func show(
        title: String,
        error: Error,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let alertView = Instance(
            title: title,
            message: error.localizedDescription,
            severity: .error,
            function: function,
            file: file,
            line: line
        )
        alertView.show()
    }

    func show() {
        instance.show()
    }

    func addCancelButton(_ title: String? = nil, action: (() -> Void)? = nil) {
        let buttonAction: (() -> Void) = action ?? {}
        addButton(title ?? "Cancel", style: .cancel, action: buttonAction)
    }

    func addButton(
        _ title: String,
        style: ButtonStyle,
        action: @escaping () -> Void
    ) {
        instance.addButton(title, style: style, action: action)
    }

    private class Instance: NSObject {
        private let title: String
        private let message: String
        private let severity: WCAlert.Severity
        private let function: String
        private let file: String
        private let line: Int
        private var normalButtons: [Button]
        private var cancelButtons: [Button]

        private var view: UIView!
        private var containerView: UIView!

        private static var queuedAlerts = [Instance]()

        private let horizontalMargin: CGFloat = 16.0
        private let verticalMargin: CGFloat = 8.0
        private var width: CGFloat {
            min(UIScreen.main.bounds.width - 2 * horizontalMargin, 600.0)
        }

        init(
            title: String,
            message: String,
            severity: WCAlert.Severity,
            function: String,
            file: String,
            line: Int
        ) {
            self.title = title
            self.message = message
            self.severity = severity
            self.function = function
            self.file = file
            self.line = line
            normalButtons = [Button]()
            cancelButtons = [Button]()
        }

        func show() {
            if !Instance.queuedAlerts.isEmpty {
                Instance.queuedAlerts.append(self)
                return
            }

            Instance.queuedAlerts.append(self)

            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first { $0.isKeyWindow }

            guard let keyWindow = keyWindow else { return }

            let view = UIView()
            self.view = view
            view.frame = UIScreen.main.bounds
            view.backgroundColor = UIColor(white: 0, alpha: 0.2)

            let titleLabel = UILabel()
            titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
            titleLabel.text = title
            titleLabel.textAlignment = .center

            let messageLabel = UILabel()
            messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
            messageLabel.textColor = UIColor.label
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0

            let containerView = UIView()
            self.containerView = containerView
            containerView.layer.cornerRadius = 6.0
            containerView.layer.masksToBounds = true

            let shadowView = UIView()
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize.zero
            shadowView.layer.shadowOpacity = 0.15
            shadowView.layer.shadowRadius = 6.0

            keyWindow.addSubview(view)

            // Automatically add an OK button if none was provided
            if normalButtons.isEmpty && cancelButtons.isEmpty {
                addButton("OK", style: .action) {}
            }

            var yPosition = CGFloat(0)

            let titleHeight = CGFloat(50.0)
            let metadataHeight = CGFloat(19.0)
            let buttonHeight = CGFloat(50.0)

            let useableWidth = width - 2 * horizontalMargin
            let useableHeight = UIScreen.main.bounds.height
                - 2 * verticalMargin // Top margins
                - titleHeight - verticalMargin // Title + margins
                - metadataHeight - verticalMargin
                - 2 * verticalMargin // Margins around message
                - buttonHeight - verticalMargin // Buttons + margins
                - 2 * verticalMargin // Bottom margins

            // Title

            if let text = titleLabel.text {
                if !text.isEmpty {
                    let frame = CGRect(x: 0, y: yPosition, width: width, height: 50)
                    let titlebarView = UIView(frame: frame)

                    containerView.addSubview(titlebarView)

                    titleLabel.frame = CGRect(
                        x: horizontalMargin,
                        y: 0,
                        width: titlebarView.frame.width - 2 * horizontalMargin,
                        height: titleHeight
                    )

                    titlebarView.addSubview(titleLabel)

                    switch severity {
                    case .success:
                        titlebarView.backgroundColor = .systemGreen
                        titleLabel.textColor = .black
                    case .info:
                        titlebarView.backgroundColor = .clear
                        titleLabel.textColor = .black
                    case .warning:
                        titlebarView.backgroundColor = .systemOrange
                        titleLabel.textColor = .black
                    case .error:
                        titlebarView.backgroundColor = .systemRed
                        titleLabel.textColor = .white
                    }

                    yPosition = titlebarView.frame.height + verticalMargin
                }
            } else {
                yPosition += verticalMargin
            }

            // Message

            messageLabel.text = message
            let messageSize = messageLabel.sizeThatFits(
                CGSize(width: useableWidth, height: useableHeight)
            )

            messageLabel.frame = CGRect(
                x: horizontalMargin,
                y: yPosition,
                width: useableWidth,
                height: min(messageSize.height, useableHeight)
            )

            containerView.addSubview(messageLabel)
            yPosition = messageLabel.frame.origin.y + messageLabel.frame.size.height + 2 * verticalMargin

            // Buttons

            var buttons = [Button]()
            buttons.append(contentsOf: cancelButtons)
            buttons.append(contentsOf: normalButtons)

            let buttonSpacing: CGFloat = 5.0
            let buttonWidth = (useableWidth - buttonSpacing * CGFloat(buttons.count + 1)) / CGFloat(buttons.count)
            for index in buttons.indices {
                let button = buttons[index]
                let xPosition = horizontalMargin + CGFloat(index) * (buttonWidth + buttonSpacing) + buttonSpacing
                button.frame = CGRect(x: xPosition, y: yPosition, width: buttonWidth, height: buttonHeight)
                containerView.addSubview(button)
            }

            if let button = buttons.first {
                yPosition = button.frame.origin.y + button.frame.size.height + verticalMargin
            }

            shadowView.frame = CGRect(x: 0, y: 0, width: width, height: yPosition)
            shadowView.center = view.center
            containerView.frame = CGRect(origin: CGPoint.zero, size: shadowView.frame.size)
            containerView.backgroundColor = UIColor.white
            shadowView.addSubview(containerView)
            view.addSubview(shadowView)

            let buttonsString = buttons
                .map { $0.titleLabel?.text ?? "" }
                .filter { !$0.isEmpty }
                .map { "'\($0)'" }
                .joined(separator: ", ")

            let logMessage =
                """
                {"control":"WCAlertView","title":"\(title)","message":"\(message)","buttons":[\(buttonsString)]}"
                """

            Log.info(logMessage, function: function, file: file, line: line)

            view.alpha = 0.0
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                options: UIView.AnimationOptions.curveEaseOut,
                animations: {
                    view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    view.alpha = 1.0
                },
                completion: nil
            )
        }

        func addButton(
            _ title: String,
            style: ButtonStyle,
            action: @escaping () -> Void
        ) {
            let button = Button(
                title: title,
                style: style,
                action: action
            )

            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            if case .cancel = style {
                cancelButtons.append(button)
            } else {
                normalButtons.append(button)
            }
        }

        @objc
        private func buttonTapped(_ button: Button) {
            if let buttonString = button.titleLabel?.text {
                Log.info(
                    "WCAlertView.buttonTapped(button='\(buttonString)')",
                    function: function,
                    file: file,
                    line: line
                )
            }

            dismiss(button.action)
        }

        func dismiss(_ action: (() -> Void)?) {
            UIView.animate(
                withDuration: 0.18,
                delay: 0.0,
                options: UIView.AnimationOptions.curveEaseOut,
                animations: {
                    self.containerView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.view.alpha = 0.0
                },
                completion: { _ in
                    self.view.removeFromSuperview()
                    if let action = action {
                        action()
                    }
                }
            )

            if !Instance.queuedAlerts.isEmpty {
                Instance.queuedAlerts.remove(at: 0)
            }

            if let alertView = Instance.queuedAlerts.first {
                alertView.show()
            }
        }
    }

    private class Button: AppButton {
        let action: () -> Void

        override var isHighlighted: Bool {
            didSet { alpha = isHighlighted ? 0.8 : 1.0 }
        }

        required init?(coder _: NSCoder) {
            fatalError("Not implemented")
        }

        init(
            title: String,
            style: ButtonStyle,
            action: @escaping (() -> Void)
        ) {
            self.action = action
            super.init(frame: CGRect.zero)

            setTitle(title, for: UIControl.State())
            titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            styleAs(style)
        }
    }
}
