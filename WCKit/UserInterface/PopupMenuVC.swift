// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public protocol PopupMenuDelegate: AnyObject {
    func popupMenuDidSelectItem(withID id: Int, tag: Int)
}

public final class PopupMenuVC: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var closeButton: UIButton!

    private var menu: PopupMenu!
    private weak var delegate: PopupMenuDelegate?

    static func make(from menu: PopupMenu, delegate: PopupMenuDelegate) -> PopupMenuVC {
        let vc: PopupMenuVC = UIViewController.makeViewController()

        vc.menu = menu
        vc.delegate = delegate

        return vc
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = menu
    }

    @IBAction
    private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension PopupMenuVC: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menu.items[indexPath.row]
        Log.info("Menu item '\(item.label)' tapped")
        dismiss(animated: true) {
            self.delegate?.popupMenuDidSelectItem(withID: item.id, tag: indexPath.row)
        }
    }
}
