// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public protocol SegmentedButtonDelegate: AnyObject {
    func segmentedButtonDidSelect(_ sender: SegmentedButton, didSelectButtonAt index: Int)
}

@IBDesignable
public final class SegmentedButton: UIView {
    // MARK: Types

    private class Segment: UIView {
        let index: Int
        let stackView: UIStackView
        let imageView: UIImageView
        let titleLabel: UILabel
        let subtitleLabel: UILabel

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError()
        }

        init(index: Int, title: String, subtitle: String?) {
            self.index = index
            stackView = UIStackView(frame: CGRect.zero)
            imageView = UIImageView(frame: CGRect.zero)
            titleLabel = UILabel(frame: CGRect.zero)
            subtitleLabel = UILabel(frame: CGRect.zero)

            super.init(frame: CGRect.zero)

            addSubview(stackView)

            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .center
            stackView.spacing = 8.0
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

            imageView.tintColor = .white
            imageView.image = Symbol(.checkmark).image
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            stackView.addArrangedSubview(imageView)

            let titlesStackView = UIStackView(frame: CGRect.zero)
            titlesStackView.axis = .vertical
            titlesStackView.distribution = .fill
            titlesStackView.alignment = .leading
            stackView.addArrangedSubview(titlesStackView)

            titlesStackView.addArrangedSubview(titleLabel)
            titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
            titleLabel.text = title

            titlesStackView.addArrangedSubview(subtitleLabel)
            subtitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
            subtitleLabel.text = subtitle
        }
    }

    // MARK: Properties

    private let stackView: UIStackView
    private var segments = [Segment]()

    weak var delegate: SegmentedButtonDelegate?

    private let primaryBackground = UIColor.black
    private let primaryForeground = UIColor.white

    private let secondaryBackground = UIColor.white
    private let secondaryForeground = UIColor.black

    public var checkedIndex: Int = -1 {
        didSet {
            for index in segments.indices {
                let segment = segments[index]
                if index == checkedIndex {
                    segment.imageView.isHidden = false
                    segment.backgroundColor = primaryBackground
                    segment.titleLabel.textColor = primaryForeground
                    segment.subtitleLabel.textColor = primaryForeground
                } else {
                    segment.imageView.isHidden = true
                    segment.backgroundColor = secondaryBackground
                    segment.titleLabel.textColor = secondaryForeground
                    segment.subtitleLabel.textColor = secondaryForeground
                }
            }

            if let delegate = delegate {
                if oldValue != checkedIndex {
                    delegate.segmentedButtonDidSelect(self, didSelectButtonAt: checkedIndex)
                }
            }
        }
    }

    // MARK: Lifetime

    required init?(coder: NSCoder) {
        stackView = UIStackView(frame: CGRect.zero)
        super.init(coder: coder)

        setupView()
    }

    override init(frame: CGRect) {
        stackView = UIStackView(frame: CGRect.zero)
        super.init(frame: frame)

        setupView()
    }

    // MARK: - Overrides

    public override func prepareForInterfaceBuilder() {
        backgroundColor = .systemGroupedBackground

        let label = UILabel(frame: CGRect.zero)

        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.text = "SegmentedButton"
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        addBorder(color: .black)
    }

    // MARK: - Helpers

    private func setupView() {
#if !TARGET_INTERFACE_BUILDER

        addSubview(stackView)

        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addBorder()

#endif
    }

    // MARK: - API

    public func removeAllSegments() {
        for segment in segments {
            stackView.removeArrangedSubview(segment)
            segment.removeFromSuperview()
        }
        segments.removeAll()
    }

    public func addSegment(title: String, subtitle: String? = nil) {
        let segment = Segment(index: segments.count, title: title, subtitle: subtitle)

        segment.isUserInteractionEnabled = true
        let segmentGR = UITapGestureRecognizer(target: self, action: #selector(segmentTapped(_:)))
        segment.addGestureRecognizer(segmentGR)

        segments.append(segment)

        stackView.addArrangedSubview(segment)
    }

    // MARK: Actions

    @objc
    private func segmentTapped(_ gestureRecognizer: UIGestureRecognizer) {
        guard let index = (gestureRecognizer.view as? Segment)?.index else {
            return
        }

        checkedIndex = index
        delegate?.segmentedButtonDidSelect(self, didSelectButtonAt: checkedIndex)
    }
}
