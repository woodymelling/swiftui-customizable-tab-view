import Testing
@testable import CustomizableTabView

import OrderedCollections
import UIKit

struct TabCustomizationTests {

    @Test
    func visibleItemsNoOverflow() {
        let customization = TabCustomization(
            visibleItems: [1, 2, 3, 4],
            overflowItems: [],
            maxVisible: 5
        )
        #expect(customization.visibleItems == [1, 2, 3, 4])
        #expect(customization.overflowItems.isEmpty)
    }

    @Test
    func visibleItemsWithOverflow() {
        // 6 items active, but maxVisible = 5 means computed visibleItems are first 4.
        let customization = TabCustomization(
            visibleItems: [1, 2, 3, 4, 5, 6],
            overflowItems: [],
            maxVisible: 5
        )
        #expect(customization.visibleItems == [1, 2, 3, 4])
        #expect(customization.overflowItems == [5, 6])
    }

    @Test
    func visibleItemsAtEdgeAmount() {
        // 5 visible items + 1 overflow item.
        let customization = TabCustomization(
            visibleItems: [1, 2, 3, 4, 5],
            overflowItems: [6],
            maxVisible: 5
        )
        #expect(customization.visibleItems == [1, 2, 3, 4])
        #expect(customization.overflowItems == [5, 6])
    }

    @Test
    func moveItemWithinVisibleSection() {
        var customization = TabCustomization(
            visibleItems: [1, 2, 3, 4, 5],
            overflowItems: [],
            maxVisible: 5
        )
        customization.moveItem(
            from: IndexPath(row: 0, section: 0),
            to: IndexPath(row: 2, section: 0)
        )
        #expect(customization.visibleItems == [2, 3, 1, 4, 5])
        #expect(customization.overflowItems.isEmpty)
    }

    @Test
    func moveItemFromVisibleToOverflow() {
        var customization = TabCustomization(
            visibleItems: [1, 2, 3, 4],
            overflowItems: [5, 6, 7],
            maxVisible: 5
        )
        customization.moveItem(
            from: IndexPath(row: 3, section: 0),
            to: IndexPath(row: 0, section: 1)
        )

        #expect(customization.visibleItems == [1, 2, 3])
        #expect(customization.overflowItems == [4, 5, 6, 7])
    }

    @Test
    func moveItemFromOverflowToVisible() {
        // Move 5 into visible. 4 should move into overflow
        var customization = TabCustomization(
            visibleItems: [1, 2, 3, 4],
            overflowItems: [5, 6],
            maxVisible: 5
        )

        customization.moveItem(
            from: IndexPath(row: 0, section: 1),
            to: IndexPath(row: 1, section: 0)
        )

        #expect(customization.visibleItems == [1, 5, 2, 3])
        #expect(customization.overflowItems == [4, 6])
    }

    @Test
    func moveItemFromTabToOverflow_DecreasesVisibleCount() {
        var customization = TabCustomization(
            visibleItems: [1, 2, 3, 4],
            overflowItems: [5, 6],
            maxVisible: 5
        )
        customization.moveItem(
            from: IndexPath(row: 0, section: 0),
            to: IndexPath(row: 0, section: 1)
        )


        #expect(customization.visibleItems == [2, 3, 4])
        #expect(customization.overflowItems == [1, 5, 6])
    }

    @Test
    func moveItemFromOverflowToTab_IncreasesVisibleCount() {
        var customization = TabCustomization(
            visibleItems: [1, 2, 3],
            overflowItems: [4, 5, 6],
            maxVisible: 5
        )
        customization.moveItem(
            from: IndexPath(row: 0, section: 1),
            to: IndexPath(row: 0, section: 0)
        )

        #expect(customization.visibleItems == [4, 1, 2, 3])
        #expect(customization.overflowItems == [5, 6])
    }

    @Test
    func moveItemFromOverflowToTabPreservesMaxVisibleCount() {
        var customization = TabCustomization(
            visibleItems: [1, 2, 3, 4],
            overflowItems: [5, 6, 7],
            maxVisible: 5
        )

        customization.moveItem(
            from: IndexPath(row: 0, section: 1),
            to: IndexPath(row: 0, section: 0)
        )

        #expect(customization.visibleItems == [5, 1, 2, 3])
        #expect(customization.overflowItems == [4, 6, 7])
    }

    @Test
    func moveItemFromOverflowToTabPreservesMaxVisibleCount_CrashReplication() {
        var customization = TabCustomization(
            visibleItems: ["A", "B", "C", "D", "E", "F", "G"],
            maxVisible: 5
        )

        customization.moveItem(
            from: IndexPath(row: 0, section: 1),
            to: IndexPath(row: 3, section: 0)
        )

        #expect(customization.visibleItems == ["A", "B", "C", "E"])
        #expect(customization.overflowItems == ["D", "F", "G"])
    }
}
