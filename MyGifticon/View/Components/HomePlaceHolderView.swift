//
//  HomePlaceHolderView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/27/25.
//

import SwiftUI
import Lottie

struct HomePlaceHolderView: View {
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                ZStack {
                    LottieView(animation: .named("Gift"))
                        .playing(loopMode: .loop)
                        .resizable()
                        .scaledToFit()
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            LottieView(animation: .named("Barcode scanning"))
                                .playing(loopMode: .loop)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .padding(20)
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                }
                        }
                        
                    }.padding(20)
                }

//                Image("icon")
//                    .resizable()
//                    .scaledToFit()
                Text("home placeholder title")
                    .font(.title)
                Text("home placeholder description")
            }
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.4))
        }
        .padding()
    }
}

#Preview {
    HomePlaceHolderView()
}
