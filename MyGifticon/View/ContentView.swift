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

fileprivate let style:KImageLabel.Style = .init(
    foregroundColor: .buttonForeground,
    backgroundColor: .buttonBackground,
    padding: 10,
    cornerRadius: 20,
    isHorizontal: true)

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
    
    var adView : some View {
        Spacer()
            .frame(height: 80)
            .listRowSeparator(.hidden)
            .opacity(0)
//        TODO : AD here
    }
    var buttons: some View {
        HStack {
            if isLoading {
                Text("Loading...")
            } else {
                KImageButton(image: .init(systemName: "document.on.clipboard.fill"),
                             title: .init("Import image from clipboard"),
                             style: style) {
                    loadClipboardImage()
                }
                
                PhotosPicker(
                    selection: $photoPickerItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        KImageLabel(image: .init(systemName:"photo"),
                                    title: .init("Select from photo library"),
                                    style: style
                        )
                    }
            }
        }.frame(height:80)
    }
    
    var listView : some View {
        VStack {
            if gifticons.count == 0 {
                HomePlaceHolderView()
                Spacer()
            } else {
                List {
                    Section {
                        GifticonListView()
                    }
                    DeletedGifticonListView()
                    
                    adView
                }
            }
            Spacer()
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                if proxy.size.width < proxy.size.height {
                    ZStack {
                        listView
                        VStack {
                            Spacer()
                            buttons
                        }
                    }
                }
                else {
                    HStack {
                        if gifticons.count == 0 {
                            HomePlaceHolderView()
                            Spacer()
                        }
                        List {
                            GifticonListView()
                        }
                        ZStack {
                            List {
                                DeletedGifticonListView()
                                adView
                            }
                            VStack {
                                Spacer()
                                buttons
                            }
                        }

                    }
                }

            }
        }
        .navigationTitle(Text("MyGifticon"))
        .navigationBarTitleDisplayMode(.inline)
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

