//
//  MyGifticonApp.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 8/19/25.
//

import SwiftUI
import SwiftData

@main
struct MyGifticonApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [GifticonModel.self])
        
    }
}
