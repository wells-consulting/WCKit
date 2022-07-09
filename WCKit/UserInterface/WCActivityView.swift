// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public final class WCActivityView: UIView {
    private var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: .zero)
        view.style = .large
        view.color = .black
        return view
    }()

    private var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private var dimmingView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        view.layer.masksToBounds = true
        return view
    }()

    private var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemGroupedBackground //   UIColor(white: 0, alpha: 0.2)
        view.layer.cornerRadius = 6.0
        view.layer.masksToBounds = true
        return view
    }()

    private var shadowView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.shadowColor = UIColor.label.cgColor
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 6.0
        return view
    }()

    public let key: String?

    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }

    private var cancelButton: UIButton?
    private var cancelAction: ((WCActivityView) -> Void)?
    private(set) var isDismissed: Bool = false

    required init?(coder aDecoder: NSCoder) {
        key = UUID().uuidString
        super.init(coder: aDecoder)
    }

    public init(key: String? = nil) {
        self.key = key
        super.init(frame: CGRect.zero)
        if let key = key { WCActivityView.instances[key] = self }
    }

    private static var instances = [String: WCActivityView]()

    public func show(
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        action: @escaping (() -> Void)
    ) {
        messageLabel.text = message

        setupView()

        isDismissed = false

        alpha = 0.0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.alpha = 1.0
            },
            completion: nil
        )

        let logMessage =
            """
            {"control":"\(type(of: self))","messsage":"\(message)"}
            """

        Log.info(logMessage, function: function, file: file, line: line)

        DispatchQueue.global().async {
            action()
        }
    }

    public func addCancelButton(action: () -> Void) {
        let button = UIButton(frame: CGRect.zero)

        button.styleAs(.cancel)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        button.setTitle("Cancel", for: UIControl.State())
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        cancelButton = button
    }

    private func setupView() {
        frame = UIScreen.main.bounds
        for subview in subviews {
            subview.removeFromSuperview()
        }

        let keyWindow = UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }

        guard let keyWindow = keyWindow else { return }

        dimmingView.frame = UIScreen.main.bounds
        keyWindow.addSubview(dimmingView)
        dimmingView.addSubview(self)

        let width: CGFloat = Runtime.isPhone ? 300.0 : 500.0

        let horizontalMargin: CGFloat = 20.0
        let verticalMargin: CGFloat = 10.0

        var yPosition = verticalMargin
        let useableWidth = width - 2 * horizontalMargin

        let activityIndictorSize: CGFloat = 50.0
        activityIndicatorView.frame = CGRect(
            x: useableWidth / 2.0 - activityIndictorSize / 2.0,
            y: yPosition,
            width: activityIndictorSize,
            height: activityIndictorSize
        )
        containerView.addSubview(activityIndicatorView)
        yPosition += (activityIndictorSize + verticalMargin)

        activityIndicatorView.startAnimating()

        let messageSize = messageLabel.sizeThatFits(CGSize(width: useableWidth, height: 9999))
        messageLabel.frame = CGRect(x: horizontalMargin, y: yPosition, width: useableWidth, height: messageSize.height)
        containerView.addSubview(messageLabel)
        yPosition += messageLabel.frame.size.height + 2 * verticalMargin

        if let button = cancelButton {
            button.frame = CGRect(x: horizontalMargin, y: yPosition, width: useableWidth, height: 50)
            containerView.addSubview(button)
            yPosition += button.frame.size.height + 2 * verticalMargin
        }

        shadowView.frame = CGRect(x: 0, y: 0, width: width, height: yPosition)
        shadowView.center = center
        containerView.frame = CGRect(origin: CGPoint.zero, size: shadowView.frame.size)
        shadowView.addSubview(containerView)
        addSubview(shadowView)
    }

    public static func dismiss(_ key: String) {
        WCActivityView.instances[key]?.dismiss()
    }

    public func dismiss() {
        isDismissed = true

        cancelAction?(self)
        cancelAction = nil
        cancelButton = nil

        dimmingView.removeFromSuperview()

        if let key = key { WCActivityView.instances.removeValue(forKey: key) }
    }

    @objc
    private func buttonTapped(_ button: UIButton) {
        dismiss()
    }
}
