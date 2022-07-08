// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation
import UIKit

public extension UIViewController {
    var identifier: String {
        "\(type(of: self))".replacingOccurrences(of: Bundle.main.bundleIdentifier!, with: "")
    }

    static func makeViewController<T: UIViewController>() -> T {
        let name = "\(T.self)"

        let storyboard = UIStoryboard(name: name, bundle: nil)

        guard let vc = storyboard.instantiateViewController(withIdentifier: name) as? T else {
            // We have to return a type T here. We could change the signature to return
            // a result type or an optional, but that would make all the call sites
            // quite ugly. So we deal with a trap here.
            fatalError("Could not find view controller with identifier \(name)")
        }

        return vc
    }

    func offsetViewForKeyboard(_ flag: Bool, keyboardOffset: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            var rect = self.view.frame

            if flag {
                rect.origin.y -= keyboardOffset
                rect.size.height += keyboardOffset
            } else {
                rect.origin.y += keyboardOffset
                rect.size.height -= keyboardOffset
            }

            self.view.frame = rect
        }
    }

    func navigate(to viewController: UIViewController) {
        // When view controllers hide the navigation bar, they typically
        // restore the bar in viewWillDisappear. This works, but does leave
        // a visual glitch when the new view controller is shown.
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func viewWillDisappearEnableAllBackNavigation() {
        navigationItem.hidesBackButton = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func show(
        _ vc: UIViewController,
        as style: UIModalPresentationStyle,
        at sourceView: UIView? = nil
    ) {
        vc.modalPresentationStyle = style

        vc.view.addBorder()

        present(vc, animated: true, completion: nil)

        if let sourceView = sourceView {
            let ppc = vc.popoverPresentationController

            let frame = CGRect(
                x: 0.0,
                y: 0.0,
                width: sourceView.frame.width,
                height: sourceView.frame.height
            )
            ppc?.permittedArrowDirections = [.any]
            ppc?.sourceView = view
            ppc?.sourceRect = sourceView.convert(frame, to: view)
        }
    }

    func popViewController(_ flag: Bool) {
        if flag { navigationController?.popViewController(animated: true) }
    }
}
