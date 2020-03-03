//
//  CommentCell+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/9/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import SafariServices

extension CommentCell {
    @objc func tapTextView(sender: UITapGestureRecognizer) {
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager

        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.location(in: myTextView)
        location.x -= myTextView.textContainerInset.left
        location.y -= myTextView.textContainerInset.top

        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        // if index is valid then do something.
        if characterIndex < myTextView.textStorage.length {

            // print the character index
            print("character index: \(characterIndex)")

            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (myTextView.attributedText.string as NSString).substring(with: myRange)
            print("character at index: \(substring)")

            // check if the tap location has a certain attribute
            let attributeName = NSAttributedString.Key.link
            let attributeValue = myTextView.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)
            if let urlString = attributeValue as? String {
                if urlString == "seemore://" {
                    guard let comment = comment else {return}
                    delegate?.cell(self, didTapSeeMoreButtonForComment: comment)
                    return
                }
                
                if let url = URL(string: urlString) {
                    parentViewController?.handleUrl(url: url)
                }
            }
        }
    }
    
    @objc func upVoteButtonDidTouch() {
        guard let comment = comment else {return}
        if comment.contentId.userId == Config.currentUser?.id {
            parentViewController?.showAlert(title: "error".localized().uppercaseFirst, message: "can't cancel vote on own publication".localized().uppercaseFirst)
            return
        }
        voteContainerView.animateUpVote {
            self.delegate?.cell(self, didTapUpVoteForComment: comment)
        }
    }
    
    @objc func downVoteButtonDidTouch() {
        guard let comment = comment else {return}
        if comment.contentId.userId == Config.currentUser?.id {
            parentViewController?.showAlert(title: "error".localized().uppercaseFirst, message: "can't cancel vote on own publication".localized().uppercaseFirst)
            return
        }
        voteContainerView.animateDownVote {
            self.delegate?.cell(self, didTapDownVoteForComment: comment)
        }
    }
    
    @objc func replyButtonDidTouch() {
        guard let comment = comment else {return}
        delegate?.cell(self, didTapReplyButtonForComment: comment)
    }
    
    @objc func retrySendingCommentDidTouch(gestureRecognizer: UITapGestureRecognizer) {
        guard let comment = comment else {return}
        delegate?.cell(self, didTapRetryForComment: comment)
    }
}
