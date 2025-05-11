//
//  TabCustomization.swift
//  swiftui-customizable-tab-view
//
//  Created by Woodrow Melling on 2/17/25.
//


import Collections

/// A model that represents your tab customization with separate visible and overflow items.
/// The public API exposes the “truncated” visible items (if total > maxVisible) and the overflow.
public struct TabCustomization<Selection: Hashable & Sendable>: Sendable, Equatable, Hashable {
    // MARK: - Stored Properties
    private var visible: OrderedSet<Selection>
    private var overflow: OrderedSet<Selection>

    /// The maximum number of items you ever want on screen (including the "More" placeholder).
    let maxVisible: Int

    /// Initializes from separate visible and overflow collections.
    public init(
        items visibleItems: OrderedSet<Selection>,
        overflowItems: OrderedSet<Selection> = [],
        maxVisible: Int
    ) {
        precondition(maxVisible > 0, "maxVisible must be > 0")
        self.visible = visibleItems
        self.overflow = overflowItems
        self.maxVisible = maxVisible

        self.enforceInvariants()
    }

    // MARK: - Public Computed Properties

    /// All items in order.
    var all: OrderedSet<Selection> {
        var combined = visible
        for item in overflow {
            combined.append(item)
        }
        return combined
    }


    var needsOverflow: Bool {
        let count = all.count
        // If the count == maxVisible, we don't need a more tab
        return all.count > maxVisible
    }

    /// The items that appear in the tab bar.
    /// If total items exceed `maxVisible`, only the first (maxVisible - 1) are shown.
    var visibleItems: OrderedSet<Selection> {
        visible
    }

    /// The overflow items (i.e. those not shown as tabs).
    /// If total items exceed `maxVisible`, this returns the items starting at index (maxVisible - 1).
    var overflowItems: OrderedSet<Selection> {
        overflow
    }

    mutating func enforceInvariants() {
        let all = all

        guard needsOverflow
        else {
            self.visible = all
            self.overflow = []

            return
        }

        let visibleCount = min(visibleItems.count, maxVisible - 1)

        self.visible = OrderedSet(all.prefix(visibleCount))
        self.overflow = OrderedSet(all.suffix(from: visibleCount))
    }
}

extension TabCustomization: Decodable where Selection: Decodable {}
extension TabCustomization: Encodable where Selection: Encodable {}


#if canImport(UIKit)
import UIKit
extension TabCustomization {
    // MARK: - Moving Items

    /// Moves an item from a source index path to a destination index path.
    /// The index paths refer to the public API:
    /// - Section 0 is the visible (or “tab”) area.
    /// - Section 1 is the overflow (“more”) area.
    mutating func moveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item: Selection? = switch sourceIndexPath.section {
        case 0:
            self.visible.remove(at: sourceIndexPath.row)
        case 1:
            self.overflow.remove(at: sourceIndexPath.row)
        default:
            nil
        }

        if let item {
            switch destinationIndexPath.section {
            case 0:
                self.visible.insert(item, at: destinationIndexPath.row)
            case 1:
                self.overflow.insert(item, at: destinationIndexPath.row)
            default:
                break
            }
        }

        self.enforceInvariants()
    }
}
#endif
