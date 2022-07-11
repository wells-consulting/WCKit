// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public final class WCToastAlertView: UIView {
    public static let tag = 17122020

    let alert: WCAlert

    private var contentView: UIView!
    private var leftAccessoryView: UIImageView!
    private var rightAccessoryView: UIImageView!
    private var titleLabel: UILabel!
    private var messageLabel: UILabel!

    private var dismissTimer: Timer?

    // MARK: Lifetime

    public init(alert: WCAlert, viewController: UIViewController?) {
        self.alert = alert

        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        contentView = UIView()
        contentView.accessibilityLabel = "Content View"
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        let foregroundColor: UIColor
        let symbol: WCSymbol

        switch alert.severity {
        case .error:
            symbol = WCSymbol(.statusError).autoTint(basedOn: .white)
            backgroundColor = UIColor.systemRed
            foregroundColor = UIColor.white
        case .warning:
            symbol = WCSymbol(.statusWarning).autoTint(basedOn: .black)
            backgroundColor = UIColor.systemOrange
            foregroundColor = UIColor.black
        case .info:
            symbol = WCSymbol(.statusInfo).autoTint(basedOn: .black)
            backgroundColor = UIColor.systemGray5
            foregroundColor = UIColor.black
        case .success:
            symbol = WCSymbol(.statusSuccess).autoTint(basedOn: .black)
            backgroundColor = UIColor.systemGreen
            foregroundColor = UIColor.black
        }

        backgroundColor!.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        let tintColor = UIColor(hue: hue, saturation: saturation, brightness: 0.6, alpha: alpha)

        let dismissTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissToast(_:)))

        leftAccessoryView = UIImageView()
        leftAccessoryView.accessibilityLabel = "Left Accessory View"
        leftAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        leftAccessoryView.tintColor = tintColor
        leftAccessoryView.image = symbol.image
        contentView.addSubview(leftAccessoryView)

        rightAccessoryView = UIImageView()
        rightAccessoryView.accessibilityLabel = "Right Accessory View"
        rightAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        rightAccessoryView.tintColor = tintColor
        rightAccessoryView.image = WCSymbol(.xmark).autoTint(basedOn: tintColor).image
        rightAccessoryView.isUserInteractionEnabled = true
        rightAccessoryView.addGestureRecognizer(dismissTapRecognizer)
        contentView.addSubview(rightAccessoryView)

        titleLabel = UILabel()
        titleLabel.text = alert.title
        titleLabel.accessibilityLabel = "Title Label"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = foregroundColor
        contentView.addSubview(titleLabel)

        messageLabel = UILabel()
        messageLabel.text = alert.message
        messageLabel.isUserInteractionEnabled = false
        messageLabel.accessibilityLabel = "Message Label"
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textColor = foregroundColor
        messageLabel.lineBreakMode = .byTruncatingMiddle
        messageLabel.numberOfLines = 0
        contentView.addSubview(messageLabel)

        let confirmTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(confirmToast(_:)))
        addGestureRecognizer(confirmTapRecognizer)
        isUserInteractionEnabled = true

        setupBasicViewContraints()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    // MARK: Private implementation

    @objc
    private func dismissTimer(_ timer: Timer) {
        guard timer.isValid else { return }

        DispatchQueue.main.async {
            self.dismiss()
        }
    }

    @objc
    private func dismissToast(_ recognizer: UITapGestureRecognizer) {
        dismiss()
    }

    @objc
    private func confirmToast(_ recognizer: UITapGestureRecognizer) {
        dismiss()
    }

    private func setupBasicViewContraints() {
        let metrics: [String: CGFloat] = [
            "minTitleLabelWidth": CGFloat(100.0),
            "minTitleLabelHeight": CGFloat(10.0),
            "minMetadataLabelHeight": CGFloat(8.0),
            "minMessageLabelHeight": CGFloat(40.0),
            "leftAccessoryWidth": CGFloat(40.0),
            "leftAccessoryHeight": CGFloat(40.0),
            "rightAccessoryWidth": CGFloat(30.0),
            "rightAccessoryHeight": CGFloat(30.0),
            "vpadding": CGFloat(4.0),
            "hpadding": CGFloat(16.0),
        ]

        let views: [String: UIView] = [
            "contentView": contentView,
            "leftAccessoryView": leftAccessoryView,
            "rightAccessoryView": rightAccessoryView,
            "titleLabel": titleLabel,
            "messageLabel": messageLabel,
        ]

        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[contentView]|",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: views
            )
        )

        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[contentView]|",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: views
            )
        )

        contentView.addConstraint(
            NSLayoutConstraint(
                item: leftAccessoryView!,
                attribute: .top,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .top,
                multiplier: 1.0,
                constant: 4.0
            )
        )

        if !rightAccessoryView.isHidden {
            contentView.addConstraint(
                NSLayoutConstraint(
                    item: rightAccessoryView!,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: contentView,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: 0.0
                )
            )

            contentView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[rightAccessoryView(==rightAccessoryHeight)]",
                    options: .directionLeadingToTrailing,
                    metrics: metrics,
                    views: views
                )
            )

            contentView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat:
                    "H:|"
                        + "-hpadding"
                        + "-[leftAccessoryView(==leftAccessoryWidth)]"
                        + "-[titleLabel(>=minTitleLabelWidth)]"
                        + "-[rightAccessoryView(==rightAccessoryWidth)]"
                        + "-hpadding"
                        + "-|",
                    options: .directionLeadingToTrailing,
                    metrics: metrics,
                    views: views
                )
            )

            contentView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat:
                    "H:|"
                        + "-hpadding"
                        + "-[leftAccessoryView(==leftAccessoryWidth)]"
                        + "-[rightAccessoryView(==rightAccessoryWidth)]"
                        + "-hpadding"
                        + "-|",
                    options: .directionLeadingToTrailing,
                    metrics: metrics,
                    views: views
                )
            )

            contentView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat:
                    "H:|"
                        + "-hpadding"
                        + "-[leftAccessoryView(==leftAccessoryWidth)]"
                        + "-[messageLabel]"
                        + "-[rightAccessoryView(==rightAccessoryWidth)]"
                        + "-hpadding"
                        + "-|",
                    options: .directionLeadingToTrailing,
                    metrics: metrics,
                    views: views
                )
            )
        } else {
            contentView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat:
                    "H:|"
                        + "-hpadding"
                        + "-[leftAccessoryView(==leftAccessoryWidth)]"
                        + "-[titleLabel(>=minTitleLabelWidth)]"
                        + "-hpadding"
                        + "-|",
                    options: .directionLeadingToTrailing,
                    metrics: metrics,
                    views: views
                )
            )

            contentView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat:
                    "H:|"
                        + "-hpadding-"
                        + "[leftAccessoryView(==leftAccessoryWidth)]"
                        + "-[rightAccessoryView(==rightAccessoryWidth)]"
                        + "-hpadding"
                        + "-|",
                    options: .directionLeadingToTrailing,
                    metrics: metrics,
                    views: views
                )
            )

            contentView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat:
                    "H:|"
                        + "-hpadding"
                        + "-[leftAccessoryView(==leftAccessoryWidth)]"
                        + "-[messageLabel]"
                        + "-hpadding"
                        + "-|",
                    options: .directionLeadingToTrailing,
                    metrics: metrics,
                    views: views
                )
            )
        }

        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[leftAccessoryView(==leftAccessoryHeight)]",
                options: .directionLeadingToTrailing,
                metrics: metrics,
                views: views
            )
        )

        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat:
                "V:|"
                    + "-vpadding"
                    + "-[titleLabel(>=minTitleLabelHeight)]"
                    + "[messageLabel(>=minMessageLabelHeight)]"
                    + "-vpadding"
                    + "-|",
                options: .directionLeadingToTrailing,
                metrics: metrics,
                views: views
            )
        )
    }

    private var _superviewConstraints: [NSLayoutConstraint]?

    private func getSuperviewConstraints() -> [NSLayoutConstraint] {
        if let svc = _superviewConstraints { return svc }
        
        var constraints = [NSLayoutConstraint]()

        constraints.append(
            contentsOf:
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-navBarHeight-[toast(>=height)]",
                options: .directionLeadingToTrailing,
                metrics: ["height": CGFloat(95.0), "navBarHeight": CGFloat(70.0)],
                views: ["toast": self]
            )
        )

        constraints.append(
            contentsOf:
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[toast]|",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: ["toast": self]
            )
        )

        _superviewConstraints = constraints

        return constraints
    }

    public func show() {
        guard let superview = superview else { return }

        superview.addConstraints(getSuperviewConstraints())

        UIView.animate(
            withDuration: 0.6,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3,
            options: [.allowAnimatedContent],
            animations: { [weak self] in
                self?.layoutIfNeeded()
            },
            completion: nil
        )

        dismissTimer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: self,
            selector: #selector(dismissTimer(_:)),
            userInfo: nil,
            repeats: false
        )
    }

    public func dismiss(notify: Bool = true) {
        if let timer = dismissTimer {
            if timer.isValid {
                timer.invalidate()
            }
        }

        guard let superview = superview else { return }

        isHidden = true
        superview.removeConstraints(getSuperviewConstraints())
        removeFromSuperview()
    }
}
