//
//  GifticonListView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/24/25.
//

import SwiftUI
import SwiftData

struct GifticonListView: View {
    @Query private var list: [GifticonModel]
    
    var body: some View {
        ForEach(list) { model in
            NavigationLink {
                GifticonView(model: model, isNew: false)
            } label: {
                Text(model.limitDateYMD)
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
