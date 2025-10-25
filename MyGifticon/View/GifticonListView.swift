//
//  GifticonListView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/24/25.
//

import SwiftUI
import SwiftData
import KongUIKit

struct GifticonListView: View {
    @Query private var list: [GifticonModel]
    
    var body: some View {
        ForEach(list) { model in
            NavigationLink {
                GifticonView(model: model, isNew: false)
            } label: {
                HStack {
                    Text(model.memo)
                        .font(.title)
                    Spacer()
                    Text(String(format: NSLocalizedString("%d days left", comment: "%d 일 남음"), model.daysUntilLimit))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(model.limitDateYMD)
                        .foregroundStyle(model.isLimitOver ? .red : .primary)
                        .font(.caption)
                    
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: GifticonModel.self, configurations: config)
        return GifticonListView()
            .modelContainer(container)
    } catch {
        return Text("Preview error: \(String(describing: error))")
    }
}
