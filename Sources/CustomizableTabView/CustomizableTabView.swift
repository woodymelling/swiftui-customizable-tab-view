//
//  Untitled.swift
//  SwiftUITesting
//
//  Created by Woodrow Melling on 1/21/25.
//


import SwiftUI


struct TabViewCustomization: View {
    @State var selectedTab: TabLocation<Int> = .more(nil)

    @State var customization: TabCustomization<Int> = .init(
        items: [1,2,3,4,5,6,7,8,9],
        maxVisible: 5
    )

    var body: some View {
        CustomizableTabView(selection: $selectedTab, customization: $customization) {

        }
    }
}



public struct CustomizableTabView<Selection: Hashable & Sendable, Content: View>: View {
    public init(
        selection: Binding<TabLocation<Selection>>,
        customization: Binding<TabCustomization<Selection>>,
        @ViewBuilder content: () -> Content
    ) {
        _selection = selection
        self._customization = customization
        self.content = content()
    }

    @Binding var selection: TabLocation<Selection>
    @Binding var customization: TabCustomization<Selection>

    var content: Content

    @State var moreDestination: Selection?
    @State var uuid = UUID()

    public var body: some View {
        TabView(selection: $selection[moreDestination]) {
            Group(subviews: content) { subviews in


                let subviews = customization.visibleItems.compactMap { item in
                    print("\(item)")
                    return subviews.first {
                        $0.containerValues.tag(for: Selection.self) == item
                    }
                }

                let _ = print("count:", subviews.count)

                ForEach(subviews) { subview in
                    subview
                        .tabItem { AnyView(subview.containerValues.label()) }
                        .tag(
                            subview
                                .containerValues.tag(for: Selection.self)
                                .map { TabLocation<Selection>.TabBarLocation.tabBar($0) }
                        )
                }
            }
            .environment(\.tabLocation, .tabBar)

            // Seperate groups because some(???) environmentValues don't work on subviews
            MoreView(
                destination: $moreDestination,
                tabCustomization: $customization,
                content: content
            )
            .tag(TabLocation<Selection>.TabBarLocation.more)
            .tabItem { Label("More", systemImage: "ellipsis") }
            .environment(\.tabLocation, .more)

        }
        .onChange(of: customization) { _, _ in
            self.uuid = UUID()
        }
        .onChange(of: moreDestination) { old, new in
            self.selection = .more(new)
        }
        .onChange(of: selection) { oldValue, newValue in
            print("Selection:", newValue)
        }
    }


    struct MoreView: View {

        @Binding var destination: Selection?
        @Binding var tabCustomization: TabCustomization<Selection>

        var content: Content

        @State var isEditing = false

        var body: some View {
            NavigationStack {
                Group {
                    if isEditing {
                        EditCustomizationsView(customization: $tabCustomization)
                            .navigationTitle("Edit Tabs")
                    } else {
                        TrueMoreView(
                            destination: $destination,
                            content: content,
                            customization: tabCustomization
                        )
                            .navigationTitle("More")
                    }
                }
                .toolbar {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            self.isEditing.toggle()
                        }
                    }
                }
            }
        }

        struct TrueMoreView: View {
            @Binding var destination: Selection?
            var content: Content
            var customization: TabCustomization<Selection>

            var body: some View {
                Group(subviews: content) { subviews in
                    List {

                        let subviews = customization.overflowItems.compactMap { item in
                            print("\(item)")
                            return subviews.first {
                                $0.containerValues.tag(for: Selection.self) == item
                            }
                        }


                        ForEach(subviews) { subview in
                            NavigationLinkButton {
                                let tag = subview.containerValues.tag(for: Selection.self)
                                self.destination = tag
                            } label: {
                                AnyView(subview.containerValues.label())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .navigationDestination(item: $destination) { selection in
                        if let dest = subviews.first(where: {
                            $0.containerValues.tag(for: Selection.self) == selection
                        }) {
                            dest.navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
            }
        }
    }
}


extension CustomizableTabView {


}


extension ContainerValues {
    @Entry var label: () -> any View = { EmptyView() }
}

enum SimplerTabLocation {
    case tabBar
    case more
}

extension EnvironmentValues {
    @Entry var maxVisibleTabs: Int = 5
    @Entry var tabLocation: SimplerTabLocation? = nil
}

struct NavigationStackTab<
    TabValue: Hashable,
    Content: View,
    Label: View
>: View where TabValue: Hashable {
    init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        value: TabValue,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == SwiftUI.Label<Text, Image> {
        self.value = value
        self.content = content
        self.label = { SwiftUI.Label(titleKey, systemImage: systemImage) }
    }

    let value: TabValue
    var content: () -> Content
    var label: () -> Label

    @Environment(\.tabLocation) var tabLocation

    var body: some View {
        Group {
            switch tabLocation {
            case .tabBar, .none:
                NavigationStack {
                    content()
                }
            case .more:
                content()

            }
        }
        .tabItem(label)
        .tag(value)
        .containerValue(\.label, label)
    }
}

#Preview {
    TabViewCustomization()
}

import SwiftUI
import UIKit

public enum TabLocation<T> {
    case tabBar(T)
    case more(T?)

    var more: T? {
        get {
            if case let .more(t) = self {
                return t
            } else {
                return nil
            }
        }

        set { self = .more(newValue) }
    }

    var tabBar: T? {
        get {
            if case let .tabBar(t) = self {
                return t
            } else {
                return nil
            }
        }

        set { self = .more(newValue) }
    }

    subscript(moreLocation: T?) -> TabBarLocation {
        get {
            switch self {
            case .tabBar(let t): .tabBar(t)
            case .more: .more
            }
        }

        set {
            switch newValue {
            case .more: self = .more(moreLocation)
            case .tabBar(let t): self = .tabBar(t)
            }
        }
    }


    enum TabBarLocation {
        case tabBar(T)
        case more
    }
}

extension TabLocation: Equatable where T: Equatable {}
extension TabLocation: Hashable where T: Hashable {}

extension TabLocation.TabBarLocation: Equatable where T: Equatable {}
extension TabLocation.TabBarLocation: Hashable where T: Hashable {}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

/// Two sections: top “Tabs” and bottom “More”.
enum TabSection: Int, CaseIterable, Sendable {
    case tab, more
}


/// Items that can appear in our diffable data source.
enum TabItem<Selection: Hashable & Sendable>: Hashable, Sendable {
    /// A real tab item (from tabItems).
    case tab(Selection)
    /// A “More” placeholder cell shown in the top section.
    case morePlaceholder
    /// An item from the dedicated moreItems (or overflow after reordering).
    case more(Selection)
}

