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
    
    var body: some View {
        VStack {
            NavigationLink {
                Image(uiImage: model.image)
                    .resizable()
                    .scaledToFit()
                    .navigationTitle("Gifticon Image")
            } label: {
                KBarcodeView(text: model.barcode, conerRadius: 20)
                    .padding(10)
                
            }
            Text(model.barcode)
                .font(.subheadline)

            HStack {
                VStack (alignment: .leading) {

                    TextField(text: $memo) {
                        Text("memo")
                    }.textFieldStyle(.roundedBorder)
                    
                    KTextScrollView(string: model.title)
                    
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
                        do {
                            modelContext.delete(model)
                            try modelContext.save()
                            dismiss()
                        } catch {
                            // Handle save error (you might want to surface this to the UI)
                            print("Failed to save model: \(error)")
                        }
                    }
                }
            }
            .frame(width: 50)
            .padding(10)
            

        }
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(.orange)
        }
        .navigationTitle(Text("Gifticon"))
        .padding()
        .onAppear {
            memo = model.memo
        }
        .onDisappear {
            do {
                model.memo = memo
                try modelContext.save()
            } catch {
                print("Failed to save model: \(error)")
            }
        }
//        .onChange(of: memo) { oldValue, newValue in
//            do {
//                model.memo = newValue
//                try modelContext.save()
//            } catch {
//                print("Failed to save model: \(error)")
//            }
//        }
    }
}

#Preview {
    GifticonView(model: .init(title: "test", barcode: "124312", limitDate: "2026.04.04", image: .init(systemName: "circle")!), isNew: true)
}
