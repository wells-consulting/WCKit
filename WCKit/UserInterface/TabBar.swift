// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public protocol TabBarDelegate: AnyObject {
    func tabBar(_ tabBar: TabBar, didSelectTab tab: TabBar.Tab)
}

@IBDesignable
public class TabBar: UIView {
    public enum TabBarType {
        case primary
        case secondary
    }

    public var tabs = [Tab]()

    public weak var delegate: TabBarDelegate!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(stackView)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    public static let nilTab = Tab()

    public var tabBarType: TabBarType = .primary

    public var selectedTab: Tab = TabBar.nilTab {
        didSet {
            guard selectedTab != oldValue else { return }
            for tab in tabs { tab.isSelected = tab == selectedTab }
            if let delegate = delegate, oldValue != selectedTab {
                delegate.tabBar(self, didSelectTab: selectedTab)
            }
        }
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect.zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public func getTab(withIdentifier identifier: String) -> Tab? {
        tabs.first(where: { $0.identifier == identifier })
    }

    public func addTab(
        identifier: String,
        showCheckmarkWhenSelected: Bool,
        accessoryImage: UIImage?
    ) -> Tab {
        let tabView = TabView(
            identifier: identifier,
            tabBarType: tabBarType,
            showCheckmarkWhenSelected: showCheckmarkWhenSelected,
            target: self,
            action: #selector(tabTapped(_:)),
            accessoryImage: accessoryImage
        )

        let tab = Tab(identifier: identifier, tabView: tabView)
        tabs.append(tab)

        stackView.addArrangedSubview(tabView)

        return tab
    }

    public func style(selectedTab: Tab) {
        for tab in tabs { tab.isSelected = tab == selectedTab }
    }

    @objc
    private func tabTapped(_ sender: UIGestureRecognizer) {
        guard sender.state == .ended else { return }

        if let identifier = sender.name, let tab = tabs.first(where: { $0.identifier == identifier }) {
            selectedTab = tab
        }
    }

    public class Tab: Equatable {
        public let identifier: String
        private let tabView: TabView?

        fileprivate init() {
            identifier = UUID().uuidString
            tabView = nil
        }

        fileprivate init(identifier: String, tabView: TabView?) {
            self.identifier = identifier
            self.tabView = tabView
        }

        @discardableResult
        public func setTitle(_ title: String) -> Tab {
            tabView?.titleLabel.text = title
            return self
        }

        public var isSelected: Bool {
            get { tabView?.isSelected ?? false }
            set { tabView?.isSelected = newValue }
        }

        public static func == (lhs: Tab, rhs: Tab) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }

    class TabView: UIView {
        let stackView: UIStackView = {
            let stackView = UIStackView(frame: CGRect.zero)
            stackView.axis = .horizontal
            stackView.spacing = 4.0
            stackView.distribution = .equalCentering
            stackView.alignment = .center
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()

        let checkmarkImageView: UIImageView = {
            let imageView = UIImageView(frame: CGRect.zero)
            imageView.image = Symbol(.checkmark).image
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
            return imageView
        }()

        let titleLabel: UILabel = {
            let label = UILabel(frame: CGRect.zero)
            label.isUserInteractionEnabled = true
            label.font = UIFont.preferredFont(forTextStyle: .body)
            return label
        }()

        let accessoryImageView: UIImageView = {
            let imageView = UIImageView(frame: CGRect.zero)
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
            return imageView
        }()

        let tabBarType: TabBarType
        let showCheckmarkWhenSelected: Bool

        @available(*, unavailable)
        required init(coder: NSCoder) {
            fatalError()
        }

        init(
            identifier: String,
            tabBarType: TabBarType,
            showCheckmarkWhenSelected: Bool,
            target: AnyObject,
            action: Selector,
            accessoryImage: UIImage?
        ) {
            self.tabBarType = tabBarType
            self.showCheckmarkWhenSelected = showCheckmarkWhenSelected

            super.init(frame: CGRect.zero)

            addSubview(stackView)
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

            let viewTapGR = UITapGestureRecognizer(target: target, action: action)
            viewTapGR.name = identifier
            addGestureRecognizer(viewTapGR)

            // Checkmark
            stackView.addArrangedSubview(checkmarkImageView)
            let checkmarkImageViewTapGR = UITapGestureRecognizer(target: target, action: action)
            checkmarkImageViewTapGR.name = identifier
            checkmarkImageView.addGestureRecognizer(checkmarkImageViewTapGR)

            // Title Label
            stackView.addArrangedSubview(titleLabel)
            let titleLabelTapGR = UITapGestureRecognizer(target: target, action: action)
            titleLabelTapGR.name = identifier
            titleLabel.addGestureRecognizer(titleLabelTapGR)

            // Accessory
            if let accessoryImage = accessoryImage {
                stackView.addArrangedSubview(accessoryImageView)
                accessoryImageView.image = accessoryImage
                let accessoryImageViewTapGR = UITapGestureRecognizer(target: target, action: action)
                accessoryImageViewTapGR.name = identifier
                accessoryImageView.addGestureRecognizer(accessoryImageViewTapGR)
            }

            styleTab()
        }

        public var isSelected: Bool = false {
            didSet { if isSelected != oldValue { styleTab() } }
        }

        private func styleTab() {
            let fgColor: UIColor
            let bgColor: UIColor

            let primaryBackground = UIColor.black
            let primaryForeground = UIColor.white

            let secondaryBackground = UIColor.white
            let secondaryForeground = UIColor.black

            let unselectedBackground = UIColor.systemGray2
            let unselectedForeground = UIColor.black

            switch tabBarType {
            case .primary:
                fgColor = isSelected ? primaryForeground : unselectedForeground
                bgColor = isSelected ? primaryBackground : unselectedBackground
            case .secondary:
                fgColor = isSelected ? secondaryForeground : unselectedForeground
                bgColor = isSelected ? secondaryBackground : unselectedBackground
            }

            backgroundColor = bgColor
            titleLabel.textColor = fgColor
            checkmarkImageView.tintColor = fgColor
            checkmarkImageView.isHidden = !showCheckmarkWhenSelected || !isSelected
        }
    }
}
