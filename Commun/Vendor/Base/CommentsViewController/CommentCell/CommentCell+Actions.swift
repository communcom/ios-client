//
//  CommentCell+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/9/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import SafariServices

extension CommentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "seemore://" {
            guard let comment = comment else {return true}
            delegate?.cell(self, didTapSeeMoreButtonForComment: comment)
            return false
        }
        
        if URL.absoluteString.isLinkToMention,
            let userName = URL.absoluteString.components(separatedBy: "@").last
        {
            parentViewController?.showProfileWithUserId(userName)
            return false
        }
        if URL.absoluteString.isLinkToTag,
            let tag = URL.absoluteString.components(separatedBy: "#").last
        {
            delegate?.cell(self, didTapOnTag: tag)
            return false
        }
        
        if URL.absoluteString.starts(with: "https://") ||
            URL.absoluteString.starts(with: "http://")
        {
            let safariVC = SFSafariViewController(url: URL)
            parentViewController?.present(safariVC, animated: true, completion: nil)
            return false
        }
        
        return false
    }
    
    @objc func upVoteButtonDidTouch() {
        guard let comment = comment else {return}
        voteContainerView.animateUpVote {
            self.delegate?.cell(self, didTapUpVoteForComment: comment)
        }
    }
    
    @objc func downVoteButtonDidTouch() {
        guard let comment = comment else {return}
        voteContainerView.animateDownVote {
            self.delegate?.cell(self, didTapDownVoteForComment: comment)
        }
    }
    
    @objc func replyButtonDidTouch() {
        guard let comment = comment else {return}
        delegate?.cell(self, didTapReplyButtonForComment: comment)
    }
    
    @objc func handleLongPressOnTextView(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let comment = comment else {return}
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            //When lognpress is finish
            self.delegate?.cell(self, didTapMoreActionFor: comment)
        }
    }
}
