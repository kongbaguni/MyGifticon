//
//  DeletedGifticonListView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/28/25.
//

import SwiftUI
import SwiftData
import jkdsUtility

struct UsedGifticonListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<GifticonModel> {
            $0.used == true
        },
        sort: \GifticonModel.limitDateYMD,
        order: .reverse
    )
    
    private var list: [GifticonModel]
    @State var confirmDelete: Bool = false
    
    var locationItem : [MapViewWithMultipleLocationInfo.Info] {
        list.map { model in
            return MapViewWithMultipleLocationInfo
                .Info(title: model.brandName ?? "",
                      location: model.usedLocation ?? .init())
        }
    }
    
    var mapView : some View {
        MapViewWithMultipleLocationInfo(infos: locationItem)
            .frame(height: 500)
    }
    
    var body: some View {
        List {
            Section {
                ForEach(list) { model in
                    NavigationLink {
                        GifticonView(model: model, isNew: false, isUsed: true)
                    } label: {
                        GifticonListRowView(model: model)
                    }
                    
                }
                .onDelete { indexset in
                    for index in indexset {
                        let item = list[index]
                        self.modelContext.delete(item)
                    }
                    try? self.modelContext.save()
                }
            }
            if list.count > 0 {
                Section {
                    mapView
                }
            }
            Section {
                Button {
                    confirmDelete = true
                } label: {
                    Label("clear used", systemImage: "trash")
                }
            }
        }
        .alert(isPresented: $confirmDelete) {
            .init(title: .init("clear used title"),
                  message: .init("clear used message"),
                  primaryButton: .cancel(),
                  secondaryButton: .default(.init("delete"), action: {
                do {
                    try GifticonModel.deleteAllUsedGifticon(context: modelContext)
                } catch {
                    Log.debug(error.localizedDescription)
                }

            }))
        }
    }
}
