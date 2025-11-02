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
    
    var filteredList: [GifticonModel] {
        guard let tag = selectedTag else { return list }
        return list.filter { $0.tag == tag.id } // 모델의 tag 필드에 맞춰 수정
    }
    
    @State private var selectedTag: KSelectView.Item? = nil
    
    @AppStorage("selectedTag") private var selectedTagRaw: Int = -1
    
    var listView: some View {
        ForEach(filteredList, id: \.self) { model in
            NavigationLink {
                GifticonView(model: model, isNew: false, isDeleted: false)
            } label: {
                GifticonListRowView(model: model)
            }
        }
        .onDelete { indexset in
            for index in indexset {
                let item = filteredList[index]
                item.deleted = true
            }
            try? self.modelContext.save()
        }
    }
    
//    var iconTestListView: some View {
//        ForEach(Consts.brands, id: \.self) { brand in
//            GifticonListRowView(model: .init(title: brand, barcode: "1231231234", limitDate: "2027.12.31", image: .init()))
//        }
//    }
    
    var body: some View {
        Group {
            KSelectView(items: GifticonModel.tags, canCancel: true, selected: $selectedTag)
            if selectedTag != nil && filteredList.isEmpty {
                Text("empty list msg when tag is selected")
            }
            listView
        }
        .onAppear {
            if selectedTagRaw > -1 {
                self.selectedTag = GifticonModel.tags[selectedTagRaw]
            } else {
                self.selectedTag = nil
            }
        }
        .onChange(of: selectedTag, {
            selectedTagRaw = selectedTag?.id ?? -1
        })
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
