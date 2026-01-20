//
//  WKWebview+Extensiopns.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 11/25/25.
//

import WebKit
import UIKit
import jkdsUtility

extension WKWebView {
    func takeFullSnapshot(completion: @escaping (UIImage?) -> Void) {
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(origin: .zero,
                             size: scrollView.contentSize) // 전체 페이지 크기

        self.takeSnapshot(with: config) { image, error in
            if let error = error {
                Log.debug("Snapshot error:", error)
            }
            completion(image)
        }
    }
}
