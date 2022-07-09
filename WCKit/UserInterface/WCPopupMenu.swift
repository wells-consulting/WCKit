// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public enum WCPopupMenuItemType {
    case destructive
    case standard
    case warning
}

public class WCPopupMenuItem {
    let id: Int
    let symbol: WCSymbol
    let label: String
    var isDisabled: Bool

    init(
        id: Int,
        symbol: WCSymbol,
        label: String,
        isDisabled: Bool
    ) {
        self.id = id
        self.symbol = symbol
        self.label = label
        self.isDisabled = isDisabled
    }
}

public final class WCPopupMenu: NSObject {
    private(set) var items = [WCPopupMenuItem]()

    public var isEmpty: Bool { items.isEmpty }

    public func addItem(
        id: Int,
        symbol: WCSymbol,
        label: String,
        isDisabled: Bool = false
    ) {
        guard !items.contains(where: { $0.id == id }) else { return }

        let item = WCPopupMenuItem(
            id: id,
            symbol: symbol,
            label: label,
            isDisabled: isDisabled
        )

        items.append(item)
    }

    public func enableItem(withID id: Int) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        item.isDisabled = false
    }

    public func disableItem(withID id: Int) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        item.isDisabled = true
    }
}

// MARK: - UITableViewDataSource

extension WCPopupMenu: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int { 1 }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PopupMenuItemTVC = tableView.makeCellFor(indexPath)
        let item = items[indexPath.row]
        cell.configure(item)
        return cell
    }
}

// MARK: -

class PopupMenuItemTVC: UITableViewCell {
    @IBOutlet private var menuItemLabel: UILabel!
    @IBOutlet private var menuItemImageView: UIImageView!
    @IBOutlet private var menuItemImageViewContainingView: UIView!

    func configure(_ item: WCPopupMenuItem) {
        menuItemLabel.text = item.label
        menuItemImageView.image = item.symbol.font(menuItemLabel.font).image
    }
}
