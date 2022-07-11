//
//  ViewController.swift
//  WCKitExamples
//
//  Created by Michael Wells on 7/7/22.
//

import UIKit
import WCKit

struct Product: Codable {
    let brand: String
    let title: String
    let thumbnail: URL?
}

struct ProductResponse: Codable {
    let products: [Product]
}

class ViewController: UIViewController {
    @IBOutlet private var menubar: WCMenubar!
    @IBOutlet private var popupMenuButton: UIButton!
    @IBOutlet private var badge: UILabel!
    @IBOutlet private var prompt: WCPromptLabel!
    @IBOutlet private var activityViewButton: UIButton!
    @IBOutlet private var toastButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    
    private var products = LoadedData<[Product]>.loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menubar.delegate = self
        
        tableView.addBorder()

        for index in MenubarParts.allCases.indices {
            let part = MenubarParts.allCases[index]
            menubar.addTextMenuItem(
                id: part.rawValue,
                state: index == 2 ? .disabled(nil) : .normal,
                initialValue: part.description
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        prompt.info(
            "Searching...",
            presentation: .custom(
                pulseDuration: 5.0) {
                    self.prompt.success("Found inner peace")
                }
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(requestedAlertNotification(_:)),
            name: WCAlert.notification,
            object: nil
        )
        
        Task {
            await loadTableView()
        }
    }

    @IBAction
    private func popupMenuButtonTapped(_ sender: UIButton) {
        let menu = WCPopupMenu()

        for condition in PopupMenuParts.allCases {
            menu.addItem(
                id: condition.rawValue,
                symbol: condition.symbol,
                label: condition.description
            )
        }

        let vc = WCPopupMenuVC.make(from: menu, delegate: self)
        show(vc, as: .popover, at: sender)
    }

    @IBAction
    private func activityViewButtonTapped(_ sender: UIButton) {
        let av = WCActivityView()
        av.show("Waiting...") {
            DispatchQueue.global().asyncAfter(
                deadline: DispatchTime.now() + .seconds(2)
            ) {
                DispatchQueue.main.async {
                    av.dismiss()
                }
            }
        }
    }
    
    @IBAction
    private func toastButtonTapped(_ sender: UIButton) {
        WCAlert.show(
            "Time for toast!",
            title: "Toast",
            severity: .warning,
            presentation: .toast
        )
    }
    
    private func loadTableView() async {
        do {
        let response: ProductResponse = try await HTTPRequestBuilder(urlPrefix: "https://dummyjson.com/")
            .appending("products")
            .get()
            DispatchQueue.main.async {
                self.products = .loaded(response.products)
                self.tableView.reloadData()
            }
        } catch {
            DispatchQueue.main.async {
                self.products = .error(error)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc
    private func requestedAlertNotification(_ notification: Notification) {
        guard let alert = notification.object as? WCAlert else { return }

        DispatchQueue.main.async {
            switch alert.presentation {
            case .toast:
                self.toastAlert(alert)
            case .modal:
                self.modalAlert(alert)
            case let .popup(viewController, view):
                self.popupAlert(alert, in: viewController, at: view)
            @unknown default:
                self.modalAlert(alert)
            }
        }
    }
    
    private func modalAlert(_ alert: WCAlert) {
        WCAlert.show(
            alert.title,
            title: alert.message,
            severity: alert.severity,
            presentation: .modal
        )
    }
    
    private func popupAlert(
        _ alert: WCAlert,
        in parentViewController: UIViewController,
        at sourceView: UIView
    ) {
        let vc = WCPopupAlertVC.make(alert: alert)
        show(vc, as: .popover, at: sourceView)
    }
    
    private func toastAlert(_ alert: WCAlert) {
        DispatchQueue.main.async {
            let toastAlertView = WCToastAlertView(
                alert: alert,
                viewController: self
            )

            toastAlertView.tag = WCToastAlertView.tag
            self.view.addSubview(toastAlertView)
            toastAlertView.show()
        }
    }
}

// MARK: - PopupMenu

enum PopupMenuParts: Int, CustomStringConvertible, CaseIterable {
    case sunny
    case cloudy
    case windy
    case raining
    case snowing

    var description: String {
        switch self {
        case .sunny: return "Sunny"
        case .cloudy: return "Cloudy"
        case .windy: return "Windy"
        case .raining: return "Raining"
        case .snowing: return "Snowing"
        }
    }

    var symbol: WCSymbol {
        switch self {
        case .sunny:
            return WCSymbol(systemName: "sun.max.fill")
                .autoTint(basedOn: .systemOrange)
        case .cloudy:
            return WCSymbol(systemName: "cloud.fill")
                .autoTint(basedOn: .systemOrange)
        case .windy:
            return WCSymbol(systemName: "wind")
                .autoTint(basedOn: .systemOrange)
        case .raining:
            return WCSymbol(systemName: "cloud.drizzle.fill")
                .autoTint(basedOn: .systemOrange)
        case .snowing:
            return WCSymbol(systemName: "cloud.snow.fill")
                .autoTint(basedOn: .systemOrange)
        }
    }
}

extension ViewController: WCPopupMenuDelegate {
    func popupMenuDidSelectItem(withID id: Int, tag: Int) {
        let text = PopupMenuParts(rawValue: id)?.description ?? String(id)

        let alert = UIAlertController(
            title: "Popup Menu",
            message: "Tapped item \(text)",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Menubar

enum MenubarParts: Int, CustomStringConvertible, CaseIterable {
    case apple
    case orange
    case lemon
    case lime

    var description: String {
        switch self {
        case .apple: return "Apple"
        case .orange: return "Orange"
        case .lemon: return "Lemon"
        case .lime: return "Lime"
        }
    }
}

extension ViewController: WCMenubarDelegate {
    func menubarDidSelectItem(withID id: Int) {
        let text = MenubarParts(rawValue: id)?.description ?? String(id)
        let alert = UIAlertController(
            title: "Menubar",
            message: "Tapped menubar item \(text)",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableView

final class ProductTVC: UITableViewCell {
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var brandLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    
    func configure(_ product: Product) {
        brandLabel.text = product.brand
        titleLabel.text = product.title
        
        if let url = product.thumbnail {
            thumbnailImageView.load(url)
        } else {
            thumbnailImageView.image = WCSymbol(.photo).image
        }
        
        thumbnailImageView.addBorder()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch products {
        case .loading, .error:
            return 1
        case let .loaded(products):
            return products.count
        @unknown default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch products {
        case .loading:
            return tableView.makeLoadingCellFor(indexPath)
        case let .error(error):
            return tableView.makeErrorCellFor(indexPath, error: error)
        case let .loaded(products):
            let product = products[indexPath.row]
            let cell: ProductTVC = tableView.makeCellFor(indexPath)
            cell.configure(product)
            return cell
        @unknown default:
            return tableView.makeErrorCellFor(indexPath, text: "Unknown error")
        }
    }
}
