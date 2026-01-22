//
//  TabView.swift
//  MyGifticon
//
//  Created by 서창열 on 1/20/26.
//

import SwiftUI

struct TabNavigationView : View {
    let items: [Text]
    @Binding var selection: Int
    
    var body: some View {
        HStack {
            ForEach(items.indices, id: \.self) { idx in
                Button(action: { selection = idx }) {
                    tabLabel(for: idx)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    private func tabLabel(for idx:Int) -> some View {
        let isSelected = (selection == idx)
        items[idx]
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
            .init("a"),
            .init("b"),
            .init("c"),
        ], selection: .constant(0))
        TabNavigationView(items: [
            .init("a"),
            .init("b"),
            .init("c"),
        ], selection: .constant(2))
    }
}

