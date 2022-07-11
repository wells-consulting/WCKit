// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public final class WCPopupAlertVC: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!

    private var alert: WCAlert!
    private var dismissTimer: Timer?

    public static func make(alert: WCAlert) -> WCPopupAlertVC {
        let name = "\(Self.self)"

        let storyboard = UIStoryboard(
            name: name,
            bundle: Bundle(for: Self.self)
        )

        guard let vc = storyboard.instantiateViewController(withIdentifier: name) as? Self else {
            // We have to return a type T here. We could change the signature to return
            // a result type or an optional, but that would make all the call sites
            // quite ugly. So we deal with a trap here.
            fatalError("Could not find view controller with identifier \(name)")
        }
        
        vc.alert = alert
        
        return vc
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch alert.severity {
        case .success:
            imageView.image = WCSymbol(.statusSuccess)
                .autoTint(basedOn: .systemGreen)
                .image
        case .info:
            imageView.image = WCSymbol(.statusInfo)
                .autoTint(basedOn: .systemGray4)
                .image
        case .warning:
            imageView.image = WCSymbol(.statusWarning)
                .autoTint(basedOn: .systemOrange)
                .image
        case .error:
            imageView.image = WCSymbol(.statusError)
                .autoTint(basedOn: .systemRed)
                .image
        }

        titleLabel.text = alert.title
        messageLabel.text = alert.message

        dismissTimer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: self,
            selector: #selector(dismissTimer(_:)),
            userInfo: nil,
            repeats: false
        )
    }

    //

    @objc
    private func dismissTimer(_ timer: Timer) {
        guard timer.isValid else { return }

        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}
