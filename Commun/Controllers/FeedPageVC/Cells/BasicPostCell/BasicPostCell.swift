//
//  BasicPostCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import SafariServices

final class BasicPostCell: PostCell {
    // MARK: - Subviews
    lazy var contentTextView        = UITextView(forExpandable: ())
    lazy var gridView               = GridView(forAutoLayout: ())

    private func configureTextView() {
        contentTextView.textContainerInset = UIEdgeInsets.zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.font = .systemFont(ofSize: 14)
        contentTextView.dataDetectorTypes = .link
        contentTextView.isEditable = false
        contentTextView.delegate = self
    }

    // MARK: - Layout
    override func layoutContent() {
        configureTextView()

        contentView.addSubview(contentTextView)
        contentTextView.autoPinEdge(.top, to: .bottom, of: metaView, withOffset: 10)
        contentTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        contentTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)

        contentView.addSubview(gridView)
        gridView.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 10)
        gridView.autoPinEdge(toSuperviewEdge: .left)
        gridView.autoPinEdge(toSuperviewEdge: .right)
        gridView.autoPinEdge(.bottom, to: .top, of: voteContainerView)
    }
    
    override func setUp(with post: ResponseAPIContentGetPost?) {
        super.setUp(with: post)
        self.accessibilityLabel = "PostCardCell"
        
        let defaultAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        
        if let content = post?.content,
            let firstSentence = content.first(where: {$0.type == "paragraph"})
        {
            let mutableAS = NSMutableAttributedString()
            var attributedText = firstSentence
                .toAttributedString(currentAttributes: defaultAttributes)
            if attributedText.length > 600 {
                let moreText = NSAttributedString(string: "... \("More".localized())", attributes: [.foregroundColor: UIColor.appMainColor, .font: UIFont.systemFont(ofSize: 14)])
                attributedText = attributedText.attributedSubstring(from: NSMakeRange(0, 400))
                mutableAS.append(moreText)
            }
            mutableAS.insert(attributedText, at: 0)

            // check last charters a space
            let spaceSymbols = "\n"
            let components = mutableAS.components(separatedBy: spaceSymbols)
            if let last = components.last, last.isEqual(to: NSAttributedString(string: "")) {
                mutableAS.deleteCharacters(in: NSRange(location: mutableAS.length - spaceSymbols.count, length: spaceSymbols.count))
            }

            contentTextView.attributedText = mutableAS
        }

        contentTextView.resolveHashTags()
        contentTextView.resolveMentions()

        gridView.setUp(embeds: post?.attachments)
    }
}

extension BasicPostCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        parentViewController?.present(safariVC, animated: true, completion: nil)
        return false
    }
}
