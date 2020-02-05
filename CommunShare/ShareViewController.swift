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
    var shareExtensionData = ShareExtensionData()

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
                let registeredTypeIdentifiers = itemProvider.registeredTypeIdentifiers.filter({ $0 != "public.heic" })
                
                // Grab data
                for registeredTypeIdentifier in registeredTypeIdentifiers {
                    if let suffix = registeredTypeIdentifier.components(separatedBy: ".").last {
                        switch suffix {
                        case "plain-text":
                            // Grab text from Note app
                            itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil, completionHandler: { (text, error) -> Void in
                                guard error == nil, let textValue = text as? String else { return }
                                self.shareExtensionData.text = textValue
                                self.saveData()
                            })

                        case "url":
                            // Grab link
                            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                                guard error == nil, let link = url as? NSURL else { return }
                                self.shareExtensionData.link = link.description
                                self.saveData()
                            })

                        case "jpeg", "png", "jpg":
                            // Grab image
                            itemProvider.loadItem(forTypeIdentifier: "public." + suffix, options: nil, completionHandler: { (data, error) in
                                guard error == nil else { return }
                                
                                if let imageURl = data as? URL {
                                    let image = UIImage(contentsOfFile: imageURl.path)
                                    self.shareExtensionData.imageData = imageURl.path.hasSuffix("png") ? image!.resizeWithSideMax()!.pngData() : image!.resizeWithSideMax()!.jpegData(compressionQuality: 1.0)
                                } else if let image = data as? UIImage {
                                    self.shareExtensionData.imageData = image.resizeWithSideMax()!.jpegData(compressionQuality: 1.0)
                                }

                                self.saveData()
                            })
                            
                        default:
                            break
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
