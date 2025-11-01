//
//  Text+Extensions.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 11/1/25.
//

import SwiftUI
extension Text {
    static var versionName:Text {
        let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        return .init(text)
    }
    
    static var buildNumber:Text {
        .init(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
    }
}
