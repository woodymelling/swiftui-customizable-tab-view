//
//  NavigationArrow.swift
//  swiftui-customizable-tab-view
//
//  Created by Woodrow Melling on 2/16/25.
//


//
//  NavigationArrow.swift
//  SwiftUITesting
//
//  Created by Woodrow Melling on 2/14/25.
//


//
//  File.swift
//  
//
//  Created by Woodrow Melling on 6/15/24.
//

import Foundation
import SwiftUI

struct NavigationArrow: View {

    init() {}

    @ScaledMetric var height = 12
    var body: some View {
        Image(systemName: "chevron.forward")
            .resizable()
            .foregroundStyle(.tertiary)
            .aspectRatio(contentMode: .fit)
            .fontWeight(.bold)
            .frame(height: self.height)
    }
}

public struct NavigationLinkButtonStyle: ButtonStyle {


    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            Spacer()
            NavigationArrow()
        }

//        .listRowBackground(background(configuration))
//        .background(background(configuration))

    }
}

// Need to do this instead of a ButtonStyle because you can't apply
// .listRowBackground inside of a ButtonStyle, and have it work in the view.
// 
struct NavigationLinkButton<Label: View>: View {

    var action: () -> Void
    var label: Label

    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    @State private var isDetectingLongPress = false


    var body: some View {
        HStack {
            label
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .tint(.primary)
            Spacer()
            NavigationArrow()
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { state in
                    withAnimation {
                        isDetectingLongPress = true
                    }
                }
                .onEnded{ _ in
                    withAnimation {
                        isDetectingLongPress = false
                    }
                    action()
                }
        )
        .listRowBackground(background(isDetectingLongPress))
        .animation(.snappy, value: isDetectingLongPress)


    }

    func background(_ isPressed: Bool) -> Color? {
        isPressed ? Color(.tertiarySystemBackground) : nil
    }
}

public extension ButtonStyle where Self == NavigationLinkButtonStyle {
    static var navigationLink: Self {
        NavigationLinkButtonStyle()
    }
}





#Preview {
    List {

        NavigationLinkButton {
            print("press")
        } label: {
            Text("Press me!")
        }
//        .buttonStyle(.navigationLink)
    }
}
