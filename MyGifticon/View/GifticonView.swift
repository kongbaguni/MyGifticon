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


fileprivate extension String {
    /// 문자열이 4자 이상이면 4글자씩 공백으로 구분해 반환
      var groupedBy4: String {
          let text = self.replacingOccurrences(of: " ", with: "")
          guard text.count > 4 else { return text }
          
          var result = ""
          for (index, char) in text.enumerated() {
              if index > 0 && index % 4 == 0 {
                  result.append(" ")
              }
              result.append(char)
          }
          return result
      }
}


struct GifticonView : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let model: GifticonModel
    let isNew:Bool
    let isDeleted:Bool
    
    @State var memo:String = ""
    @State var tagItem: KSelectView.Item? = nil
    @State var willDelete:Bool = false
    @State var willRestore:Bool = false
    
    func barcodeView(width: CGFloat)-> some View {
        VStack(alignment: .center) {
            KBarcodeView(text: model.barcode, conerRadius: 20)
            HStack (alignment: .center) {
                Text(model.barcode.groupedBy4)
                    .font(.headline)
                    .foregroundStyle(.black)
                NavigationLink {
                    Image(uiImage: model.image)
                        .resizable()
                        .scaledToFit()
                        .navigationTitle("Gifticon Image")
                    
                } label: {
                    Image(systemName: "text.rectangle.page")
                        .foregroundStyle(.teal)
                }
                
            }
            .frame(width: width > 0 ? width : 100)
            .padding(.top, -35)
        }
    }
    
    var brandImageView: some View {
        model.brandImage
            .resizable()
            .scaledToFit()
            .frame(height: 50)
            .padding(.leading, 10)
    }
    
    var inputView : some View {
        VStack {
            TextField(text: $memo) {
                Text("memo")
            }.textFieldStyle(.roundedBorder)
            KSelectView(items: GifticonModel.tags, selected: $tagItem)

        }
    }
    
    var infoView: some View {
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
    
    var buttonView : some View {
        HStack {
            Spacer()
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
        .frame(height: 90)
    }
    
    var body: some View {
        GeometryReader { proxy in
            if !isLandscape {
                VStack (alignment: .leading) {
                    barcodeView(width: proxy.size.width)
                    
                    brandImageView
                    
                    inputView
                    
                    infoView
                    
                    Spacer()
                    buttonView
                }
            } else {
                HStack {
                    VStack {
                        brandImageView
                            .padding()
                        Spacer()
                    }.frame(width: 100)

                    ScrollView {
                        barcodeView(width: proxy.size.width - 200)
                        inputView
                    }
                    
                    VStack {
                        Spacer()
                        buttonView
                    }.frame(width: 80)

                }
            }
        }
        .padding(10)
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
