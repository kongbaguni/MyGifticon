//
//  View+Extensions.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 11/4/25.
//
import SwiftUI

extension View {
    @ViewBuilder
    func safeGlassEffect(useInteractive: Bool = false, inShape: some Shape) -> some View {
        if #available(iOS 26.0, *) {
            if useInteractive {
                self.glassEffect(.clear.interactive(), in: inShape)
            }
            else {
                self.glassEffect(.clear, in: inShape)
            }
        } else {
            self
        }
    }
}
