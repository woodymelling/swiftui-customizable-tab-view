//
//  EditTabCustomizationsViewController.swift
//  swiftui-customizable-tab-view
//
//  Created by Woodrow Melling on 2/16/25.
//

import UIKit
import SwiftUI



class EditTabCustomizationsViewController<Selection: Hashable & Sendable>: UITableViewController {
    init(
        customization: TabCustomization<Selection>,
        onCustomizationChange: @escaping (TabCustomization<Selection>) -> Void
    ) {
        self.customization = customization
        self.onCustomizationChange = onCustomizationChange

        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dataSource: DataSource!

    // Our customization model.
    var customization: TabCustomization<Selection>

    /// A callback that notifies when the customization changes.
    var onCustomizationChange: ((TabCustomization<Selection>) -> Void)?

    class DataSource:
        UITableViewDiffableDataSource<TabSection, TabItem<Selection>>
    {
        var onMoveRow: ((IndexPath, IndexPath) -> Void)?

        func updateSnapshot(
            customization: TabCustomization<Selection>,
            animatingDifferences: Bool = true
        ) {
            var snapshot = NSDiffableDataSourceSnapshot<TabSection, TabItem<Selection>>()
            snapshot.appendSections([.tab, .more])

            if customization.all.count > customization.maxVisible {
                let visibleTabs = customization.visibleItems
                snapshot.appendItems(visibleTabs.map { .tab($0) }, toSection: .tab)
                snapshot.appendItems([.morePlaceholder], toSection: .tab)
            } else {
                snapshot.appendItems(customization.all.map { .tab($0) }, toSection: .tab)
            }

            let overflow = customization.overflowItems
            snapshot.appendItems(overflow.map { .more($0) }, toSection: .more)

            self.apply(snapshot, animatingDifferences: true)
        }

        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            // Disallow moving the "More" placeholder.
            return switch self.itemIdentifier(for: indexPath) {
            case .morePlaceholder: false
            default: true
            }
        }

        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .none
        }

        override func tableView(
            _ tableView: UITableView,
            moveRowAt sourceIndexPath: IndexPath,
            to destinationIndexPath: IndexPath
        ) {
            onMoveRow?(sourceIndexPath, destinationIndexPath)
        }

        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            switch self.sectionIdentifier(for: section) {
            case .more: return "More"
            case .tab: return "Tabs"
            case .none: return ""
            }
        }
    }

    /// Maximum allowed cells in the top ("Tabs") section.
    let maxTabItems = 5

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tab Customization"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.isEditing = true  // Enable editing for deletion and reordering.

        configureDataSource()
        dataSource.updateSnapshot(
            customization: customization,
            animatingDifferences: false
        )

        tableView.dataSource = dataSource
        tableView.delegate = self

        // Set up the move callback.
        dataSource.onMoveRow = { [weak self] sourceIndexPath, destinationIndexPath in
            guard let self = self else { return }
            // Update your model using your helper method.
            self.customization.moveItem(from: sourceIndexPath, to: destinationIndexPath)
            // Refresh the UI.
            self.dataSource.updateSnapshot(customization: self.customization, animatingDifferences: true)
            // Inform SwiftUI about the change.
            self.onCustomizationChange?(self.customization)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Disallow moving the "More" placeholder.
        return switch self.dataSource.itemIdentifier(for: indexPath) {
        case .morePlaceholder: false
        default: true
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func configureDataSource() {
        dataSource = DataSource(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            switch item {
            case .tab(let selection):
                cell.textLabel?.text = "Tab: \(selection)"
            case .morePlaceholder:
                cell.textLabel?.text = "More"
            case .more(let selection):
                cell.textLabel?.text = "More: \(selection)"
            }
            cell.shouldIndentWhileEditing = false
            return cell
        }
    }
}

struct EditCustomizationsView<Selection: Sendable & Hashable>: UIViewControllerRepresentable {
    @Binding var customization: TabCustomization<Selection>

    func makeUIViewController(context: Context) -> EditTabCustomizationsViewController<Selection> {
        let vc = EditTabCustomizationsViewController<Selection>(customization: customization) { @MainActor in
            customization = $0
        }
        // Initialize with the current binding value.
        vc.customization = customization
        // Set up the callback so that changes from the controller update the binding.
        vc.onCustomizationChange = { @MainActor updatedCustomization in
            self.customization = updatedCustomization
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: EditTabCustomizationsViewController<Selection>, context: Context) {
        // Update the view controller if the binding changes.
        uiViewController.customization = customization
        uiViewController.dataSource.updateSnapshot(customization: customization, animatingDifferences: true)
    }
}


#Preview {
    @Previewable @State
    var customization: TabCustomization<String> = .init(
        items: ["A", "B", "C", "D", "E", "F", "G"],
        maxVisible: 5
    )

    NavigationStack {
        EditCustomizationsView(customization: $customization)
    }
}
