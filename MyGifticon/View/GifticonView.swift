//
//  GifticonView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/24/25.
//

import SwiftUI
import KongUIKit
import SwiftData

struct GifticonView : View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let model: GifticonModel
    let isNew:Bool
    var body: some View {
        VStack {
            Image(uiImage: model.image)
                .resizable()
                .scaledToFit()
                .padding(50)
            Text(model.limitDateYMD) + Text(" 까지 사용 가능")
            if isNew {
                KImageButton(image: .init(systemName: "plus")) {
                    do {
                        modelContext.insert(model)
                        try modelContext.save()
                        dismiss()
                    } catch {
                        // Handle save error (you might want to surface this to the UI)
                        print("Failed to save model: \(error)")
                    }
                }.frame(width: 50)
            } else {
                KImageButton(image: .init(systemName: "trash")) {
                    do {
                        modelContext.delete(model)
                        try modelContext.save()
                        dismiss()
                    } catch {
                        // Handle save error (you might want to surface this to the UI)
                        print("Failed to save model: \(error)")
                    }
                }.frame(width: 50)
            }

        }
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(.orange)
        }
        .padding()
    }
}

#Preview {
    GifticonView(model: .init(title: "test", barcode: "124312", limitDate: "2024.04.04", image: .init(systemName: "circle")!), isNew: true)
}
