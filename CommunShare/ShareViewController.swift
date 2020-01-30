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
    // MARK: - Class Functions
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first {
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                        if (url as? NSURL) != nil {
                            // send url to server to share the link
                        }
                        
                        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                    })
                }
            }
        }
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
}
