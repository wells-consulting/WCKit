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

    public static func make(from menu: PopupMenu, delegate: PopupMenuDelegate) -> PopupMenuVC {

        let name = "\(Self.self)"

        let storyboard = UIStoryboard(
            name: name,
            bundle: Bundle.init(for: PopupMenuVC.self)
        )

        guard let vc = storyboard.instantiateViewController(withIdentifier: name) as? Self else {
            // We have to return a type T here. We could change the signature to return
            // a result type or an optional, but that would make all the call sites
            // quite ugly. So we deal with a trap here.
            fatalError("Could not find view controller with identifier \(name)")
        }

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
