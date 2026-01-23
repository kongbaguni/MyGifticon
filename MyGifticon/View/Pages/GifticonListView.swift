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
        filter: #Predicate<GifticonModel> { $0.used == false },
        sort: [SortDescriptor(\.limitDateYMD, order: .reverse)]
    )
    private var list: [GifticonModel]

    @Query(
        filter: #Predicate<GifticonModel> { $0.used == true },
        sort: [SortDescriptor(\.limitDateYMD, order: .reverse)]
    )
    private var usedlist: [GifticonModel]

    var isNeedTab:Bool {
        list.count > 0 && usedlist.count > 0
    }
    
    var filteredList: [GifticonModel] {
        guard let tag = selectedTag else { return list }
        return list.filter { $0.tag == tag.id } // 모델의 tag 필드에 맞춰 수정
    }
    
    @State private var selectedTag: KSelectView.Item? = nil
    
    @AppStorage("selectedTag") private var selectedTagRaw: Int = -1
    
    var items: some View {
        ForEach(filteredList, id: \.self) { model in
            NavigationLink {
                GifticonView(model: model, isNew: false, isUsed: false)
            } label: {
                GifticonListRowView(model: model)
            }
        }
    }
        
    var version : some View {
        HStack {
            Text("version")
                .font(.body)
                .foregroundStyle(.secondary)
            Text.versionName
                .font(.body.bold())
                .foregroundStyle(.primary)
        }
    }
    var listView : some View {
        List {
            Section {
                KSelectView(items: GifticonModel.tags, canCancel: true, selected: $selectedTag)
                if selectedTag != nil && filteredList.isEmpty {
                    Text("empty list msg when tag is selected")
                }
                items
            }
            
            Section {
                version
            }
        }
        .onAppear {
            if selectedTagRaw > -1 {
                self.selectedTag = GifticonModel.tags[selectedTagRaw]
            } else {
                self.selectedTag = nil
            }
            UserNotificationManager.requestNotificationPermission {granted, error in
                for item in list {
                    UserNotificationManager
                        .scheduleExpireNotification(model: item, daysBefore: 3)
                }
            }
        }
        .onChange(of: selectedTag, {
            selectedTagRaw = selectedTag?.id ?? -1
        })
    }
    
    var body: some View {
        DirectionReader { isLandscape in
            listView
                .contentMargins(.top, (!isLandscape && isNeedTab) ? 80 : 0)
                .contentMargins(.bottom, 50)
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
