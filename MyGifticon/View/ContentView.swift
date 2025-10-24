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
    @State private var recognizedText: String = ""
    @State private var barcodeString: String = ""
    @State private var limitDate: String = ""
    var body: some View {
        VStack(spacing: 20) {
            if let image = clipboardImage {
                KImageButton(image: .init(uiImage: image)) {
                    
                }
                .frame(height: 300)
            } else {
                Text("클립보드에 이미지 없음")
                    .foregroundColor(.gray)
            }
            
            Button("클립보드에서 이미지 가져오기") {
                loadClipboardImage()
            }
            
            Button(action: {}) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 24))
            }
            
            Button("OCR & QR/바코드 인식") {
                if let image = clipboardImage {
                    image.getGifticon { data in
                        barcodeString = data?.barcode ?? ""
                        recognizedText = data?.title ?? ""
                        limitDate = data?.limitDate ?? ""
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("OCR 추출 텍스트:")
                    .bold()
                    .foregroundStyle(.secondary)
                Text(recognizedText)
            
                Text("유효기간")
                    .bold()
                    .foregroundStyle(.secondary)
                Text(limitDate)
                
                Text("바코드/QR코드 문자열:")
                    .bold()
                    .foregroundStyle(.secondary)
                Text(barcodeString)
            }
            .padding()
        }
        .padding()
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

