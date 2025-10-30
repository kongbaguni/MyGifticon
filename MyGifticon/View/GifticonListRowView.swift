//
//  GifticonListRowView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/29/25.
//

import SwiftUI

struct GifticonListRowView: View {
    let model: GifticonModel
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(model.tagItem.color)
                .frame(width: 10)
            model.brandImage
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            VStack (alignment: .leading) {
                Text(model.memo)
                
                if model.isLimitOver {
                    Text("Limit over")
                        .foregroundStyle(.red)
                        .font(.caption)
                } else {
                    Text(String(format: NSLocalizedString("%d days left", comment: "%d 일 남음"), model.daysUntilLimit))
                        .font(.caption)
                        .foregroundStyle( model.daysUntilLimit <= 3 ? .red : .secondary)
                }
                
                Text(model.limitDateYMD)
                    .foregroundStyle(model.daysUntilLimit <= 3 ? .red : .primary)
                    .font(.caption)
            }
            Spacer()
        }
    }
}

#Preview {
    List {
        ForEach(Array(Consts.brands.enumerated()), id: \.offset) { idx, brand in
            GifticonListRowView(model: .init(title: "\(brand) 2027.12.20 아메리카노", barcode: "123123123", limitDate: "2025.11.20", image: .init()))

        }
    }
}
