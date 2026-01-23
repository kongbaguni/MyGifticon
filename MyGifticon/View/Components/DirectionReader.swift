//
//  DirectionReader.swift
//  MyGifticon
//
//  Created by 서창열 on 1/23/26.
//
import SwiftUI
import Foundation

struct DirectionReader<Content: View>: View {
    @Environment(\.horizontalSizeClass) var h
    @Environment(\.verticalSizeClass) var v
    
    @ViewBuilder
    let content: (Bool) -> Content

    var body: some View {
        content(h == .regular && v == .compact)
    }
}

#Preview {
    DirectionReader { isLandscape in
        Text("!!")
    }
}
