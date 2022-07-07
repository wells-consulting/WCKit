// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public final class TableView: UITableView {
    private static let smallVerticalPadding: CGFloat = 16.0
    private static let largeVerticalPadding: CGFloat = 20.0
    private static let spacing: CGFloat = 16.0

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // Register standard cells
        register(LoadingTVC.self, forCellReuseIdentifier: "\(LoadingTVC.self)")
        register(ErrorTVC.self, forCellReuseIdentifier: "\(ErrorTVC.self)")
        register(TextTVC.self, forCellReuseIdentifier: "\(TextTVC.self)")
        register(SelectListTVC.self, forCellReuseIdentifier: "\(SelectListTVC.self)")

        sectionHeaderHeight = 50
        contentInsetAdjustmentBehavior = .never

        let emptyRect = CGRect(x: 0, y: 0, width: bounds.size.width, height: CGFloat.leastNormalMagnitude)
        tableFooterView = UIView(frame: emptyRect)
        tableHeaderView = UIView(frame: emptyRect)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        separatorStyle = .singleLine
        separatorInset = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        separatorColor = .darkGray
    }

    // MARK: TextTVC

    fileprivate class TextTVC: UITableViewCell {
        let label: UILabel = {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(label)

            label.leadingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.leadingAnchor
            ).isActive = true

            label.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            ).isActive = true

            label.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ).isActive = true

            label.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: largeVerticalPadding
            ).isActive = true

            label.bottomAnchor.constraint(
                greaterThanOrEqualTo: contentView.bottomAnchor,
                constant: largeVerticalPadding
            ).isActive = true
        }

        func configure(text: String) {
            label.text = text
        }
    }

    // MARK: ErrorTVC

    class ErrorTVC: UITableViewCell {
        let label: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let symbolImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = Symbol(.statusError).autoTint(basedOn: .systemRed).image
            return imageView
        }()

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(label)
            contentView.addSubview(symbolImageView)

            symbolImageView.widthAnchor.constraint(
                equalToConstant: CGFloat(50.0)
            ).isActive = true

            symbolImageView.heightAnchor.constraint(
                equalToConstant: CGFloat(50.0)
            ).isActive = true

            symbolImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ).isActive = true

            symbolImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: TableView.spacing
            ).isActive = true

            symbolImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: TableView.largeVerticalPadding
            ).isActive = true

            symbolImageView.bottomAnchor.constraint(
                greaterThanOrEqualTo: contentView.bottomAnchor,
                constant: TableView.largeVerticalPadding
            ).isActive = true

            symbolImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ).isActive = true

            label.leadingAnchor.constraint(
                equalTo: symbolImageView.layoutMarginsGuide.trailingAnchor,
                constant: TableView.spacing
            ).isActive = true

            label.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            ).isActive = true

            label.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: TableView.largeVerticalPadding
            ).isActive = true

            label.bottomAnchor.constraint(
                greaterThanOrEqualTo: contentView.bottomAnchor,
                constant: TableView.largeVerticalPadding
            ).isActive = true
        }

        func configure(text: String) {
            label.text = text
        }
    }

    // MARK: LoadingTVC

    class LoadingTVC: UITableViewCell {
        let label: UILabel = {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let spinner: UIActivityIndicatorView = {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .black
            spinner.style = .large
            spinner.translatesAutoresizingMaskIntoConstraints = false
            return spinner
        }()

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(label)
            contentView.addSubview(spinner)

            spinner.leadingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.leadingAnchor
            ).isActive = true

            spinner.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: TableView.largeVerticalPadding
            ).isActive = true

            spinner.bottomAnchor.constraint(
                greaterThanOrEqualTo: contentView.bottomAnchor,
                constant: TableView.largeVerticalPadding
            ).isActive = true

            spinner.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ).isActive = true

            label.leadingAnchor.constraint(
                equalTo: spinner.trailingAnchor,
                constant: TableView.spacing
            ).isActive = true

            label.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            ).isActive = true

            label.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ).isActive = true
        }

        func configure(text: String) {
            label.text = text
            spinner.startAnimating()
        }
    }

    // MARK: SelectListTVC

    fileprivate class SelectListTVC: UITableViewCell {
        let label: UILabel = {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.textColor = .black
            label.lineBreakMode = .byTruncatingMiddle
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let symbolImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemBlue
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = Symbol(.checkmark).color(UIColor.tintColor).image
            return imageView
        }()

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(symbolImageView)
            contentView.addSubview(label)

            symbolImageView.widthAnchor.constraint(
                equalToConstant: 40.0
            ).isActive = true

            symbolImageView.heightAnchor.constraint(
                equalToConstant: 40.0
            ).isActive = true

            symbolImageView.leadingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.leadingAnchor
            ).isActive = true

            symbolImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ).isActive = true

            symbolImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: TableView.smallVerticalPadding
            ).isActive = true

            symbolImageView.bottomAnchor.constraint(
                greaterThanOrEqualTo: contentView.bottomAnchor,
                constant: TableView.smallVerticalPadding
            ).isActive = true

            label.leadingAnchor.constraint(
                equalTo: symbolImageView.trailingAnchor,
                constant: TableView.spacing
            ).isActive = true

            label.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            ).isActive = true

            label.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ).isActive = true

            label.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: TableView.smallVerticalPadding
            ).isActive = true

            label.bottomAnchor.constraint(
                greaterThanOrEqualTo: contentView.bottomAnchor,
                constant: TableView.smallVerticalPadding
            ).isActive = true
        }

        func configure(text: String, isSelected: Bool) {
            label.text = text
            symbolImageView.isHidden = !isSelected
        }
    }
}

extension UITableView {
    public func makeCellFor<T: UITableViewCell>(_ indexPath: IndexPath) -> T {
        let identifier = "\(T.self)"

        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            // We have to return a type T here. We could change the signature to return
            // a result type or an optional, but that would make all the call sites
            // quite ugly. So we deal with a trap here.
            fatalError("failed to create \(identifier) at \(indexPath)") // Too bad, but what else can we do?
        }

        return cell
    }

    public func makeLoadingCellFor(_ indexPath: IndexPath, text: String = "Loading...") -> UITableViewCell {
        let cell: TableView.LoadingTVC = makeCellFor(indexPath)
        cell.configure(text: text)
        return cell
    }

    public func makeEmptyCellFor(_ indexPath: IndexPath) -> UITableViewCell {
        makeTextCellFor(indexPath, text: "Nothing found to display")
    }

    public func makeTextCellFor(_ indexPath: IndexPath, text: String) -> UITableViewCell {
        let cell: TableView.TextTVC = makeCellFor(indexPath)
        cell.configure(text: text)
        return cell
    }

    public func makeSelectListCellFor(
        _ indexPath: IndexPath,
        text: String,
        isSelected: Bool
    ) -> UITableViewCell {
        let cell: TableView.SelectListTVC = makeCellFor(indexPath)
        cell.configure(text: text, isSelected: isSelected)
        return cell
    }

    public func makeErrorCellFor(_ indexPath: IndexPath, error: Error) -> UITableViewCell {
        makeErrorCellFor(indexPath, text: error.localizedDescription)
    }

    public func makeErrorCellFor(_ indexPath: IndexPath, text: String) -> UITableViewCell {
        let cell: TableView.ErrorTVC = makeCellFor(indexPath)
        cell.configure(text: text)
        return cell
    }

    // MARK: Header

    public func makeHeaderView(title: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        view.backgroundColor = .systemGray6

        let topBorderView = UIView(frame: .zero)
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        topBorderView.backgroundColor = .systemGray4
        view.addSubview(topBorderView)

        topBorderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topBorderView.heightAnchor.constraint(equalToConstant: 1.50).isActive = true
        topBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .label
        view.addSubview(label)

        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        let bottomBorderView = UIView(frame: .zero)
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderView.backgroundColor = .label
        view.addSubview(bottomBorderView)

        bottomBorderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBorderView.heightAnchor.constraint(equalToConstant: 1.50).isActive = true
        bottomBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        return view
    }

    // MARK: - Utilities

    private func insertRow(at indexPath: IndexPath) {
        insertRows(at: [indexPath], with: .automatic)
    }

    private func reloadRow(at indexPath: IndexPath) {
        reloadRows(at: [indexPath], with: .automatic)
    }

    private func deleteRow(at indexPath: IndexPath) {
        deleteRows(at: [indexPath], with: .automatic)
    }

    private func cellContaining(_ view: UIView) -> (UITableViewCell?, IndexPath?) {
        let point = view.convert(CGPoint.zero, to: self)

        guard let indexPath = indexPathForRow(at: point) else {
            return (nil, nil)
        }

        guard let cell = cellForRow(at: indexPath) else {
            return (nil, indexPath)
        }

        return (cell, indexPath)
    }
}
