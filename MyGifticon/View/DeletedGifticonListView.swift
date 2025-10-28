//
//  DeletedGifticonListView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/28/25.
//

import SwiftUI
import SwiftData

struct DeletedGifticonListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<GifticonModel> {
            $0.deleted == true
        },
        sort: \GifticonModel.limitDateYMD,
        order: .reverse
    )
    
    private var list: [GifticonModel]
    @State var confirmDelete: Bool = false
    
    var body: some View {
        Group {
            if list.count > 0 {
                Section("deleted") {
                    ForEach(list) { model in
                        NavigationLink {
                            DeletedGifticonView(model: model)
                        } label: {
                            HStack {
                                Circle().fill(model.tagItem.color).frame(width: 20)
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
                    .onDelete { indexset in
                        for index in indexset {
                            let item = list[index]
                            self.modelContext.delete(item)
                        }
                        try? self.modelContext.save()
                    }
                    Button {
                        confirmDelete = true
                    } label: {
                        Label("clear deleted", systemImage: "trash")
                    }
                }
            }
        }
        .alert(isPresented: $confirmDelete) {
            .init(title: .init("clear deleted title"),
                  message: .init("clear deleted message"),
                  primaryButton: .cancel(),
                  secondaryButton: .default(.init("delete"), action: {
                do {
                    try GifticonModel.deleteMarkedGifticons(context: modelContext)
                } catch {
                    print(error.localizedDescription)
                }

            }))
        }
    }
}
