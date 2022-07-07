// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public final class MenubarPart {
    enum Content {
        case text(String)
        case field(String, String)
    }

    private var content: Content
    fileprivate var locatorText: String {
        switch content {
        case let .text(value):
            return value
        case let .field(label, value):
            return label + ": " + value
        }
    }

    let id: Int
    private(set) var state: ControlState

    var isDisabled: Bool { state.isDisabled }
    var isHidden: Bool { state.isHidden }

    init(id: Int, state: ControlState, initialValue: String) {
        self.id = id
        self.state = state
        content = .text(initialValue)
    }

    init(id: Int, state: ControlState, label: String, initialValue: String) {
        self.id = id
        self.state = state
        content = .field(label, initialValue)
    }

    fileprivate func setState(_ state: ControlState) { self.state = state }

    fileprivate func setValue(_ value: String) {
        switch content {
        case .text:
            content = .text(value)
        case let .field(label, _):
            content = .field(label, value)
        }
    }

    private let labelTextColor = UIColor.secondaryLabel
    private let valueTextColor = UIColor.black
    private let disabledTextColor = UIColor.systemGray

    func addToBuilder(_ builder: AttributedStringBuilder) {
        guard !isHidden else { return }

        switch content {
        case let .text(value):
            let color = isDisabled ? disabledTextColor : valueTextColor
            builder.appendText(value, color: color)

        case let .field(label, value):
            builder.appendText(label + ": ", color: isDisabled ? disabledTextColor : labelTextColor)
            builder.appendText(value, color: isDisabled ? disabledTextColor : valueTextColor)
        }
    }
}

protocol MenubarDelegate: AnyObject {
    func menubarDidSelectItem(withID id: Int)
}

public class Menubar: UILabel {
    weak var delegate: MenubarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped)))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped)))
    }

    @objc
    func labelTapped(gesture: UITapGestureRecognizer) {
        guard isEnabled else { return }

        let tapPoint = gesture.location(in: self)

        let textContainer = NSTextContainer(size: frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let attributedText = buldAttributedString()

        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)

        let index = layoutManager.characterIndex(
            for: CGPoint(x: tapPoint.x, y: tapPoint.y - 8.0),
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        let rawText = attributedText.string

        for item in items where !item.isHidden && !item.isDisabled {
            let text = item.locatorText
            if let nsRange: NSRange = rawText.range(of: text)?.nsRange(in: rawText), nsRange.contains(index) {
                delegate?.menubarDidSelectItem(withID: item.id)
                return
            }
        }
    }

    // MARK: - Items

    private var items = [MenubarPart]()

    func addTextMenuItem(
        id: Int,
        state: ControlState,
        initialValue: String
    ) {
        guard !items.contains(where: { $0.id == id }) else { return }

        let item = MenubarPart(id: id, state: state, initialValue: initialValue)
        items.append(item)
        update()
    }

    func addFieldMenuItem(
        id: Int,
        state: ControlState,
        label: String,
        initialValue: String
    ) {
        guard !items.contains(where: { $0.id == id }) else { return }

        let item = MenubarPart(id: id, state: state, label: label, initialValue: initialValue)
        items.append(item)
        update()
    }

    func setState(_ state: ControlState, forItemWithID id: Int) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        item.setState(state)
        update()
    }

    func setValue(_ value: String, forItemWithID id: Int) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        item.setValue(value)
        update()
    }

    func enableItem(withID id: Int) { setState(.normal, forItemWithID: id) }
    func disableItem(withID id: Int) { setState(.disabled(nil), forItemWithID: id) }
    func disableItemIf(_ flag: Bool, forItemWithID id: Int) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        item.setState(flag ? .normal : .disabled(nil))
        update()
    }

    func showItem(withID id: Int) { setState(.normal, forItemWithID: id) }
    func hideItem(withID id: Int) { setState(.hidden, forItemWithID: id) }
    func hideItemIf(_ flag: Bool, forItemWithID id: Int) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        item.setState(flag ? .hidden : .normal)
        update()
    }

    // MARK: Update

    private func update() {
        attributedText = buldAttributedString()
    }

    private let separatorColor = UIColor.black

    var showMenuSymbol: Bool = true {
        didSet {
            update()
        }
    }

    private func buldAttributedString() -> NSAttributedString {
        let builder = AttributedStringBuilder(font: R.fonts.menubar)

        if showMenuSymbol {
            let symbol = Symbol(.menubarIndicator)
                .palette(foregroundColor: .black, backgroundColor: .systemGray3)
            builder.appendSymbol(symbol)
            builder.appendSpacer(count: 1)
        }

        for index in items.indices {
            let item = items[index]

            guard !item.isHidden else { continue }

            item.addToBuilder(builder)

            if index != items.count - 1 {
                builder.appendText(" | ", color: separatorColor)
            }
        }

        return builder.buildAttributedString()
    }
}
