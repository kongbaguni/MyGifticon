//
//  MainButtons.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 11/3/25.
//

import SwiftUI
import KongUIKit
import PhotosUI

fileprivate let style:KImageLabel.Style = .init(
    foregroundColor: .buttonForeground,
    backgroundColor: .buttonBackground,
    padding: 10,
    cornerRadius: 20,
    isHorizontal: true)

struct MainButtons: View {
    @Binding var photoPickerItem: PhotosPickerItem?
    let onTouch:() ->Void
    @State var isOpen: Bool = false
    
    var button: some View {
        HStack {
            Spacer()
            KImageButton(image: .init(systemName: "document.on.clipboard.fill"),
                         title: .init("Import image from clipboard"),
                         style: style) {
                onTouch()
                
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
            
            KImageButton(image: .init(systemName: "minus"), title: nil, style: style) {
                isOpen = false
            }.frame(width: 80, height: 80)
        }
    }
    
    var body: some View {
        Group {
            if isOpen {
                button
            } else {
                HStack {
                    Spacer()
                    KImageButton(image: .init(systemName:"plus"), title: nil, style: style) {
                        isOpen = true
                    }.frame(width: 80, height: 80)
                }
            }
        }
        .frame(height:80)
        
    }
}

#Preview {
    MainButtons(photoPickerItem: .constant(nil)) {
        
    }

}
