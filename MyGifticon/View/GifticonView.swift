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
    let isDeleted:Bool
    
    @State var memo:String = ""
    @State var tagItem: KSelectView.Item? = nil
    @State var willDelete:Bool = false
    @State var willRestore:Bool = false
    
    var body: some View {
        VStack {
            model.brandImage
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .padding(.top, 10)

            KBarcodeView(text: model.barcode, conerRadius: 20)
                .padding(10)

            HStack {
                Text(model.barcode)
                    .font(.title)
                
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
                    
                    HStack {
                        Text(String(format: NSLocalizedString("until %@", comment: "까지"), model.limitDateYMD))
                            .foregroundStyle(model.isLimitOver ? .red : .primary)
                        Spacer()
                        if model.isLimitOver {
                            Text("Limit over")
                                .foregroundStyle(.red)
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
                    KImageButton(
                        image: .init(systemName: "plus"),
                        title: .init("save"),
                        style: .simple) {
                        do {
                            modelContext.insert(model)
                            try modelContext.save()
                            dismiss()
                        } catch {
                            // Handle save error (you might want to surface this to the UI)
                            print("Failed to save model: \(error)")
                        }
                    }
                }
                else if isDeleted {
                    KImageButton(
                        image: .init(systemName: "arrow.uturn.backward.circle"),
                        title: .init("restore"),
                        style: .simple) {
                        willRestore = true
                        dismiss()
                    }
                }
                else {
                    KImageButton(
                        image: .init(systemName: "trash"),
                        title: .init("delete"),
                        style: .simple) {
                        willDelete = true
                        dismiss()
                    }
                }
            }
            .frame(width: 200, height: 100)
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
                if isDeleted {
                    model.deleted = willRestore ? false : true
                }
                else if willDelete {
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
    GifticonView(model: .init(title: "투썸플레이스 치즈케이크 test", barcode: "124312", limitDate: "2026.04.04", image: .init(systemName: "circle")!), isNew: true, isDeleted: false)
}
