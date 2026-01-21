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
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    
    @Query(
        filter: #Predicate<GifticonModel> {
            $0.used == false
        },
        sort: \GifticonModel.limitDateYMD,
        order: .reverse
    )
    private var gifticons: [GifticonModel]
    
    @Query(
        filter: #Predicate<GifticonModel> {
            $0.used == true
        },
        sort: \GifticonModel.limitDateYMD,
        order: .reverse
    )
    private var usedGifticons: [GifticonModel]
    
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
    @State private var url:URL? = nil
    
    @State private var tabIdx:Int = 0
    
    var adView : some View {
        GeometryReader { geomentry in
            VStack(alignment: .trailing) {
                HStack {
                    Text("version")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text.versionName
                        .font(.body.bold())
                        .foregroundStyle(.primary)
                }
                Spacer()
                BannerAdView(sizeType: .AdSizeLargeBanner)
                    .mask {
                        RoundedRectangle(cornerRadius: 10)
                    }
                    .frame(width: geomentry.size.width)
                
            }
            .listRowSeparator(.hidden)
        }.frame(height: 160)
    }
    
    var buttons: some View {
        MainButtons(photoPickerItem: $photoPickerItem) {
            loadClipboardImage()
        }.padding(20)
    }
    
    var listView : some View {
        VStack {
            if gifticons.count == 0 {
                HomePlaceHolderView()
                Spacer()
            } else {
                if usedGifticons.count > 0  && gifticons.count > 0 {
                    navigationTab
                    List {
                        switch tabIdx {
                        case 0:
                            Section("Gifticon") {
                                GifticonListView()
                            }
                        case 1:
                            UsedGifticonListView()
                        default:
                            EmptyView()
                        }
                        adView
                    }
                }
                else if gifticons.count > 0 {
                    List {
                        GifticonListView()
                    }
                }
                else if usedGifticons.count > 0 {
                    List {
                        UsedGifticonListView()
                    }
                }
            }
            Spacer()
        }
    }
    
    var navigationTab : some View {
        TabNavigationView(items: [
            .init(id: 0, title: .init("Gifticon")),
            .init(id: 1, title: .init("Used"))
        ], selection: $tabIdx)
    }
    
    var mainView: some View {
        GeometryReader { proxy in
            NavigationStack {
                if !isLandscape {
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
                            Section("Gifticon") {
                                GifticonListView()
                            }
                        }
                        ZStack {
                            List {
                                UsedGifticonListView()
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

    }
    
    
    var body: some View {
        ZStack {
            if let url = url {
                WebPageToImageView(
                    url: url,
                    onSnapshot: { image in
                        guard let image else { return }
                        self.clipboardImage = image
                    }
                )
            }
            mainView
        }
        .navigationTitle(Text("MyGifticon"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: clipboardImage) { oldValue, newValue in
            Task {
                if let image = clipboardImage {
                    isLoading = true
                    image.getGifticon { data, error in
                        newGifticonModel = data
                        newGifticonModel?.urlString = self.url?.absoluteString ?? ""
                        isLoading = false
                        self.url = nil
                        if error != nil {
                            self.error = error
                        }
                        self.photoPickerItem = nil
                    }
                }
            }
        }
        .onChange(of: photoPickerItem, { oldValue, newValue in
            Task {
                if let data = try? await photoPickerItem?.loadTransferable(type: Data.self) {
                    let uiImage = UIImage(data: data)
                    self.clipboardImage = uiImage
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
                    GifticonView(model: model, isNew: true, isUsed: false)
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
        if let url = pasteboard.url {
            self.url = url
        }
        else if let image = pasteboard.image {
            self.clipboardImage = image
        }
        else {
            self.error = GifticonError.notFoundGifticonAtClipboard
        }
    }
    
 
}
