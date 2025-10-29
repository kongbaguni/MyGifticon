//
//  ShareViewController.swift
//  share
//
//  Created by Changyeol Seo on 10/29/25.
//

import UIKit
import Social

import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSharedImage { image in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    private func loadSharedImage(completion: @escaping (UIImage?) -> Void) {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = item.attachments else {
            completion(nil)
            return
        }
        
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { data, error in
                    if let url = data as? URL,
                       let imgData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imgData) {
                        completion(uiImage)
                        return
                    } else if let uiImage = data as? UIImage { // UIImage로 직접 오는 경우
                        completion(uiImage)
                        return
                    }
                    completion(nil)
                }
            }
        }
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        
        if let image = imageView.image,
           let data = image.jpegData(compressionQuality: 0.9) {
            let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.MyGifticon")
            sharedDefaults?.set(data, forKey: "sharedImageData")
        }
        
        
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}
