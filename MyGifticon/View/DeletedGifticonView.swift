//
//  DeletedGifticonView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/29/25.
//
import SwiftUI
import SwiftData

struct DeletedGifticonView : View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let model: GifticonModel

    var body: some View {
        Image(uiImage: model.image)
            .resizable()
            .scaledToFit()
            .navigationTitle(.init("Gifticon Image"))
            .toolbar {
                Button {
                    model.deleted = false
                    try? modelContext.save()
                    dismiss()
                } label: {
                    Label("undo delete", systemImage: "arrow.uturn.backward.circle")
                }
            }
    }
}
