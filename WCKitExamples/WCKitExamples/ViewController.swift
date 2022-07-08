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
    @IBOutlet private var menubar: Menubar!
    @IBOutlet private var popupMenu: UIButton!
    @IBOutlet private var badge: UILabel!
    @IBOutlet private var prompt: PromptLabel!
    @IBOutlet private var activityViewButton: UIButton!
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
        
        Task {
            await loadTableView()
        }
    }

    @IBAction
    private func popupMenuButtonTapped(_ sender: UIButton) {
        let menu = PopupMenu()

        for condition in PopupMenuParts.allCases {
            menu.addItem(
                id: condition.rawValue,
                symbol: condition.symbol,
                label: condition.description
            )
        }

        let vc = PopupMenuVC.make(from: menu, delegate: self)
        show(vc, as: .popover, at: sender)
    }

    @IBAction
    private func activityViewButtonTapped(_ sender: UIButton) {
        let av = ActivityView()
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

    var symbol: Symbol {
        switch self {
        case .sunny:
            return Symbol(name: "sun.max.fill")
                .autoTint(basedOn: .systemOrange)
        case .cloudy:
            return Symbol(name: "cloud.fill")
                .autoTint(basedOn: .systemOrange)
        case .windy:
            return Symbol(name: "wind")
                .autoTint(basedOn: .systemOrange)
        case .raining:
            return Symbol(name: "cloud.drizzle.fill")
                .autoTint(basedOn: .systemOrange)
        case .snowing:
            return Symbol(name: "cloud.snow.fill")
                .autoTint(basedOn: .systemOrange)
        }
    }
}

extension ViewController: PopupMenuDelegate {
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
    case tangerine

    var description: String {
        switch self {
        case .apple: return "Apple"
        case .orange: return "Orange"
        case .lemon: return "Lemon"
        case .lime: return "Lime"
        case .tangerine: return "Tangerine"
        }
    }
}

extension ViewController: MenubarDelegate {
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
