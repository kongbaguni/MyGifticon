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

struct ContentView: View {
    @State private var clipboardImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var newGifticonModel: GifticonModel? = nil
    
    @State private var isSheetPresented: Bool = false
    @State private var isLoading: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    Text("Loading...")
                    
                } else {
                    Button("Import image from clipboard") {
                        loadClipboardImage()
                    }
                    
                    PhotosPicker(
                        selection: $photoPickerItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Label("사진 선택", systemImage: "photo")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                }
                List {
                    GifticonListView()
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
                    image.getGifticon { data in
                        newGifticonModel = data
                        isLoading = false
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
                    GifticonView(model: model, isNew: true)
                }.navigationBarTitleDisplayMode(.inline)
            } else {
                Text("??")
            }
        }
        
        
    }
    
    // MARK: - 클립보드 이미지 가져오기
    func loadClipboardImage() {
        let pasteboard = UIPasteboard.general
        if let image = pasteboard.image {
            clipboardImage = image
        } else {
            clipboardImage = nil
        }
    }
    
 
}

