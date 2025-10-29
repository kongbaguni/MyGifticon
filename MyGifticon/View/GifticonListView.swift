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
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<GifticonModel> { $0.deleted == false },
        sort: [SortDescriptor(\.limitDateYMD, order: .reverse)]
    )
    private var list: [GifticonModel]
    
    var body: some View {
        
        ForEach(list) { model in
            NavigationLink {
                GifticonView(model: model, isNew: false, isDeleted: false)
            } label: {
               GifticonListRowView(model: model)
            }
        }
        .onDelete { indexset in
            for index in indexset {
                let item = list[index]
                item.deleted = true
            }
            try? self.modelContext.save()
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
