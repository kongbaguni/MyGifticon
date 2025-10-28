//
//  GifticonView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/24/25.
//

import SwiftUI
import KongUIKit
import SwiftData
import KongUIKit

struct GifticonView : View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let model: GifticonModel
    let isNew:Bool
    @State var memo:String = ""
    @State var tagItem: KSelectView.Item? = nil
    @State var willDelete:Bool = false
    
    var body: some View {
        VStack {
            KBarcodeView(text: model.barcode, conerRadius: 20)
                .padding(10)

            HStack {
                Text(model.barcode)
                    .font(.subheadline)
                
                NavigationLink {
                    Image(uiImage: model.image)
                        .resizable()
                        .scaledToFit()
                        .navigationTitle("Gifticon Image")
                } label: {
                    Image(systemName: "text.rectangle.page")
                }
            }
            
 
            HStack {
                VStack (alignment: .leading) {

                    TextField(text: $memo) {
                        Text("memo")
                    }.textFieldStyle(.roundedBorder)
                    
                    KSelectView(items: GifticonModel.tags, selected: $tagItem)
                    
                    KTextScrollView(string: model.title, style:
                            .init(backgroundColor: .secondary.opacity(0.3),
                                  foregroundColor: .primary,
                                  cornerRadius: 5))
                    
                    HStack {
                        Text(String(format: NSLocalizedString("until %@", comment: "까지"), model.limitDateYMD))
                            .foregroundStyle(model.isLimitOver ? .red : .primary)
                        Spacer()
                        if model.isLimitOver {
                            Text("Limit over")
                        }
                        else {
                            Text(String(format: NSLocalizedString("%d days left", comment: "%d 일 남음"), model.daysUntilLimit))
                        }
                    }
                }
                Spacer()
            }.padding(10)
            
            Spacer()
            
            Group {
                if isNew {
                    KImageButton(image: .init(systemName: "plus"), style: .simple) {
                        do {
                            modelContext.insert(model)
                            try modelContext.save()
                            dismiss()
                        } catch {
                            // Handle save error (you might want to surface this to the UI)
                            print("Failed to save model: \(error)")
                        }
                    }
                } else {
                    KImageButton(image: .init(systemName: "trash"), style: .simple) {
                        willDelete = true
                        dismiss()
                    }
                }
            }
            .frame(width: 50)
            .padding(10)
        }
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.background)
        }
        .navigationTitle(Text("Gifticon"))
        .padding()
        .onAppear {
            memo = model.memo
            tagItem = model.tagItem
        }
        .onDisappear {
            do {
                model.memo = memo
                model.tag = tagItem?.id ?? 0
                if willDelete {
                    model.deleted = true
                }
                try modelContext.save()
            } catch {
                print("Failed to save model: \(error)")
            }
        }

    }
}

#Preview {
    GifticonView(model: .init(title: "test", barcode: "124312", limitDate: "2026.04.04", image: .init(systemName: "circle")!), isNew: true)
}
