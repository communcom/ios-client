//
//  PostHeaderView+UITextViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import SafariServices

extension PostHeaderView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString.isLinkToMention,
            let userName = URL.absoluteString.components(separatedBy: "@").last {
            parentViewController?.showProfileWithUserId(userName)
            return false
        }
        if URL.absoluteString.isLinkToTag,
            let _ = URL.absoluteString.components(separatedBy: "#").last {
            //TODO: show post with tags
            return false
        }
        
        if URL.absoluteString.starts(with: "https://") ||
            URL.absoluteString.starts(with: "http://") {
            let safariVC = SFSafariViewController(url: URL)
            parentViewController?.present(safariVC, animated: true, completion: nil)
            return false
        }
        
        return false
    }
}
