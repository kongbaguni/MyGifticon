//
//  MainButtons.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 11/3/25.
//

import SwiftUI
import KongUIKit
import PhotosUI
import Lottie

fileprivate let style:KImageLabel.Style = .init(
    foregroundColor: .buttonForeground,
    backgroundColor: .buttonBackground,
    padding: 10,
    cornerRadius: 20,
    isHorizontal: true)

struct MainButtons: View {
    @Binding var photoPickerItem: PhotosPickerItem?
    let onTouch:() ->Void
    @AppStorage("bottomButtonIsOpen") var isOpen: Bool = false
    var minButton : some View {
        Button {
            isOpen = false
        } label: {
            LottieView(animation: .named("Minus"))
                .playing(loopMode: .playOnce)
        }
        .background {
            Circle()
                .fill(.secondary.opacity(0.2))
        }
        .frame(width: 40, height: 40)
    }
    
    var plusButton : some View {
        Button {
            isOpen = true
        } label: {
            LottieView(animation: .named("Plus"))
                .playing(loopMode: .playOnce)
        }
        .background {
            Circle()
                .fill(.secondary.opacity(0.2))
        }
        .frame(width: 40, height: 40)
    }
    
    var timer : some View {
        TimerView(time: .seconds(20)) {
            isOpen = false
        }
    }
    
    var button: some View {
        VStack {
            HStack(alignment:.bottom) {
                Spacer()
                VStack(alignment: .trailing) {
                    Group {
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
                    }.frame(height: 45)
                        
                }

            }
            HStack {
                Spacer()
                if isOpen {
                    timer.frame(height:40)
                }
                minButton.safeGlassEffect(useInteractive: true, inShape: .circle)
            }

        }
    }
    
    var body: some View {
        Group {
            if isOpen {
                button
            } else {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        plusButton.safeGlassEffect(useInteractive: true, inShape: .circle)
                    }
                }
            }
        }
        .frame(height:200)
        .animation(.easeInOut, value: isOpen)
        .onDisappear {
            isOpen = false
        }
        
    }
}

#Preview {
    MainButtons(photoPickerItem: .constant(nil)) {
        
    }

}
