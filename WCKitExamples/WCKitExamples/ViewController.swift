//
//  ViewController.swift
//  WCKitExamples
//
//  Created by Michael Wells on 7/7/22.
//

import UIKit
import WCKit

// swiftlint:disable all

class ViewController: UIViewController {
    @IBOutlet private var menubar: Menubar!
    @IBOutlet private var popupMenu: UIButton!
    @IBOutlet private var badge: UILabel!
    @IBOutlet private var prompt: PromptLabel!
    @IBOutlet private var tabBar: TabBar!
    @IBOutlet private var segmentedButton: SegmentedButton!
    @IBOutlet private var activityViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menubar.delegate = self
        
        for index in MenubarParts.allCases.indices {
            let part = MenubarParts.allCases[index]
            menubar.addTextMenuItem(
                id: part.rawValue,
                state: index == 2 ? .disabled(nil) : .normal,
                initialValue: part.description
            )
        }
        
        badge.text = "It's Happy Hour"
        
        tabBar.addTab(
            identifier: "Yes",
            showCheckmarkWhenSelected: true,
            accessoryImage: nil
        ).setTitle("Yes")
        
        tabBar.addTab(
            identifier: "No",
            showCheckmarkWhenSelected: true,
            accessoryImage: nil
        ).setTitle("No")
        
        tabBar.addTab(
            identifier: "Maybe",
            showCheckmarkWhenSelected: true,
            accessoryImage: nil
        ).setTitle("Maybe")
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
    }
    
    @IBAction
    func popupMenuButtonTapped(_ sender: UIButton) {
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
    func activityViewButtonTapped(_ sender: UIButton) {
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
    case cat
    case dog
    case pig
    case snake
    case rock
    
    var description: String {
        switch self {
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .pig: return "Pig"
        case .snake: return "Snake"
        case .rock: return "Rock"
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

