//
//  ContentView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 8/19/25.
//

import SwiftUI
import UIKit
import KongUIKit

struct ContentView: View {
    @State private var clipboardImage: UIImage?
    @State private var newGifticonModel: GifticonModel? = nil {
        didSet {
            if newGifticonModel != nil {
                isSheetPresented = true
            }
        }
    }
    
    @State private var isSheetPresented: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                Button("Import image from clipboard") {
                    loadClipboardImage()
                }
                List {
                    GifticonListView()
                }
            }
            .navigationTitle(Text("home"))
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
            if let image = clipboardImage {
                image.getGifticon { data in
                    newGifticonModel = data
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            if let model = newGifticonModel {
                GifticonView(model: model, isNew: true)
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

