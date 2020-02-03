//
//  ShareViewController.swift
//  CommunShare
//
//  Created by Sergey Monastyrskiy on 29.01.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    // MARK: - Properties
    let shareExtensionData = ShareExtensionData()

    // MARK: - Class Functions
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {

        // https://inneka.com/programming/swift/ios-share-extension-grabbing-url-in-swift/
        if let item = extensionContext?.inputItems.first as? NSExtensionItem, let attachments = item.attachments {
            shareExtensionData.text = self.contentText
            
            if let itemProvider = attachments.first {
                // Grab data
                for registeredTypeIdentifier in itemProvider.registeredTypeIdentifiers {
                    if let suffix = registeredTypeIdentifier.components(separatedBy: ".").last {
                        switch suffix {
                        case "url":
                            // Grab link
                            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                                guard error == nil, let link = url as? NSURL else { return }
                                self.shareExtensionData.link = link.description
                                self.saveData()
                            })

                        default:
                            // Grab image
                            itemProvider.loadItem(forTypeIdentifier: "public." + suffix, options: nil, completionHandler: { (data, error) in
                                guard error == nil else { return }

                                var image: UIImage?
                                           
                                if let someURl = data as? URL {
                                    image = UIImage(contentsOfFile: someURl.path)
                                } else if let someImage = data as? UIImage {
                                    image = someImage
                                }
                                
                                if let someImage = image {
                                    guard let compressedImagePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("shareImage.jpg", isDirectory: false) else {
                                        return
                                    }
                                    
                                    let compressedImageData = someImage.jpegData(compressionQuality: 1)

                                    guard (try? compressedImageData?.write(to: compressedImagePath)) != nil else { return }
                                    
                                    self.shareExtensionData.image = someImage
                                    self.saveData()
                                } else {
                                    print("bad share data")
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

    // MARK: - Custom Functions
    private func saveData() {
        // Save share data
        guard UserDefaults.appGroups.save(shareExtensionData: shareExtensionData) == true else { return }
        
        // URL Scheme
        guard let url = URL(string: "commun://createPost") else { return }
        
        var responder: UIResponder? = self
        let selectorOpenURL = sel_registerName("openURL:")

        while responder != nil {
            if responder?.responds(to: selectorOpenURL) == true {
                responder?.perform(selectorOpenURL, with: url)
            }

            responder = responder?.next
        }
        
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
