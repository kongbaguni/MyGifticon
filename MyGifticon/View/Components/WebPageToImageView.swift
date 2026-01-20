//
//  WebPageToImageView.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 11/25/25.
//


import SwiftUI
import WebKit
import jkdsUtility

struct WebPageToImageView: UIViewRepresentable {
    let url: URL
    let onSnapshot: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        webView.load(URLRequest(url: url))

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebPageToImageView

        init(_ parent: WebPageToImageView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 0.3초 정도 딜레이 주면 렌더링 안정화됨
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                webView.takeFullSnapshot { image in
                    self.parent.onSnapshot(image)
                }
            }
        }
    }
}
#Preview {
    VStack {
        WebPageToImageView(url: URL(string:"https://google.com")!, onSnapshot: { image in
            Log.debug(image?.size ?? .zero)
        })
    }
}
