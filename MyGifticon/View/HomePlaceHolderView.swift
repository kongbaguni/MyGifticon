//
//  HomePlaceHolderView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 10/27/25.
//

import SwiftUI

struct HomePlaceHolderView: View {
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Image("icon")
                    .resizable()
                    .scaledToFit()
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
