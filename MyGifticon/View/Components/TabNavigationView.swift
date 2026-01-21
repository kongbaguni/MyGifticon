//
//  TabView.swift
//  MyGifticon
//
//  Created by 서창열 on 1/20/26.
//

import SwiftUI

struct TabItem : Equatable {
    static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        lhs.id == rhs.id
    }
    let id: Int
    let title: Text
}

struct TabNavigationView : View {
    let items: [TabItem]
    @Binding var selection: Int
    
    var body: some View {
        HStack {
            ForEach(items, id: \.id) { (item: TabItem) in
                Button(action: { selection = item.id }) {
                    tabLabel(for: item)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    private func tabLabel(for item: TabItem) -> some View {
        let isSelected = (selection == item.id)
        item.title
            .fontWeight(isSelected ? .bold : .regular)
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
    }
}

#Preview {
    VStack {
        TabNavigationView(items: [
            .init(id: 0, title: .init("a")),
            .init(id: 1, title: .init("b")),
            .init(id: 2, title: .init("c")),
        ], selection: .constant(0))
        TabNavigationView(items: [
            .init(id: 0, title: .init("a")),
            .init(id: 1, title: .init("b")),
            .init(id: 2, title: .init("c")),
        ], selection: .constant(2))
    }
}

