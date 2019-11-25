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
        upVote()
    }
    
    @objc func downVoteButtonDidTouch() {
        downVote()
    }
    
    @objc func replyButtonDidTouch() {
        guard let comment = comment else {return}
        delegate?.cell(self, didTapReplyButtonForComment: comment)
    }
    
    @objc func handleLongPressOnTextView(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let comment = comment else {return}
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            //When lognpress is finish
            let headerView = UIView(frame: .zero)
            
            let avatarImageView = MyAvatarImageView(size: 40)
            headerView.addSubview(avatarImageView)
            avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
            
            let nameLabel = UILabel.with(textSize: 15, weight: .bold)
            headerView.addSubview(nameLabel)
            nameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
            nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
            nameLabel.autoPinEdge(toSuperviewEdge: .trailing)
            
            let actions: [CommunActionSheet.Action]
            
            if comment.author?.userId == Config.currentUser?.id {
                // edit, delete
                actions = [
                    CommunActionSheet.Action(
                        title: "edit".localized().uppercaseFirst,
                        icon: UIImage(named: "edit"),
                        handle: {
                            guard let comment = self.comment else {return}
                            self.delegate?.cell(self, didTapEditForComment: comment)
                        },
                        tintColor: .black),
                    CommunActionSheet.Action(
                        title: "delete".localized().uppercaseFirst,
                        icon: UIImage(named: "delete"),
                        handle: {
                            self.deleteComment()
                        },
                        tintColor: UIColor(hexString: "#ED2C5B")!)
                ]
            }
            else {
                // report
                actions = [
                    CommunActionSheet.Action(
                        title: "report".localized().uppercaseFirst,
                        icon: UIImage(named: "report"),
                        handle: {
                            self.report()
                        },
                        tintColor: UIColor(hexString: "#ED2C5B")!)
                ]
            }
            
            parentViewController?.showCommunActionSheet(
                headerView: headerView,
                actions: actions,
                completion: {
                    avatarImageView.setAvatar(urlString: comment.author?.avatarUrl, namePlaceHolder: comment.author?.username ?? "U")
                    nameLabel.text = comment.author?.username
                })
        }
    }
}
