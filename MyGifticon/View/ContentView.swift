//
//  ContentView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 8/19/25.
//

import SwiftUI
import UIKit
import KongUIKit
import PhotosUI
import SwiftData

struct ContentView: View {
    @Query(sort: \GifticonModel.createdAt, order: .reverse)
    private var gifticons: [GifticonModel]
    
    @State private var clipboardImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var newGifticonModel: GifticonModel? = nil
    
    @State private var isSheetPresented: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var error:Error? = nil {
        didSet {
            Task {
                if error != nil {
                    isAlert = true
                }
            }
        }
    }
    @State private var isAlert:Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                if gifticons.count == 0 {
                    HomePlaceHolderView()
                } else {
                    List {
                        Section {
                            GifticonListView()
                        }
                        DeletedGifticonListView()
                    }
                }
                if isLoading {
                    Text("Loading...")
                } else {
                    HStack {
                        Button {
                            loadClipboardImage()
                        } label: {
                            Label("Import image from clipboard", systemImage: "document.on.clipboard.fill")
                                .font(.subheadline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        PhotosPicker(
                            selection: $photoPickerItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Label("Select from photo library", systemImage: "photo")
                                    .font(.subheadline)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                    }
                }
            }
            .navigationTitle(Text("MyGifticon"))
            .navigationBarTitleDisplayMode(.inline)
            .onDrop(of: [.image], isTargeted: nil, perform: { providers in
                if let provider = providers.first {
                    _ = provider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.clipboardImage = image
                            }
                        }
                    }
                    return true
                }
                return false
            })
        }
        .padding()
       
        .onChange(of: clipboardImage) { oldValue, newValue in
            Task {
                if let image = clipboardImage {
                    isLoading = true
                    image.getGifticon { data, error in
                        newGifticonModel = data
                        isLoading = false
                        if error != nil {
                            self.error = error
                        }
                    }
                }
            }
        }
        .onChange(of: photoPickerItem, { oldValue, newValue in
            Task {
                if let data = try? await photoPickerItem?.loadTransferable(type: Data.self) {
                    let uiImage = UIImage(data: data)
                    self.clipboardImage = uiImage
                    photoPickerItem = nil
                }
            }
                
        })
        .onChange(of: newGifticonModel, { oldValue, newValue in
            Task {
                if newValue != nil {
                    isSheetPresented = true
                }
            }
        })
        .sheet(isPresented: $isSheetPresented) {
            if let model = newGifticonModel {
                NavigationStack {
                    GifticonView(model: model, isNew: true, isDeleted: false)
                }.navigationBarTitleDisplayMode(.inline)
            } else {
                Text("??")
            }
        }
        .alert(isPresented: $isAlert) {
            return .init(title: .init("alert"), message: .init(error?.localizedDescription ?? ""))
        }
        
        
    }
    
    // MARK: - 클립보드 이미지 가져오기
    func loadClipboardImage() {
        let pasteboard = UIPasteboard.general
        if let image = pasteboard.image {
            clipboardImage = image
        } else {
            clipboardImage = nil
            error = GifticonError.notFoundGifticonAtClipboard
        }
    }
    
 
}

