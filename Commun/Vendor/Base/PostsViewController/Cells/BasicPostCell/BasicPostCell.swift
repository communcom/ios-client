//
//  BasicPostCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import SafariServices

final class BasicPostCell: PostCell {
    // MARK: - Properties
    private var centerConstraint: NSLayoutConstraint!
    // MARK: - Subviews
    lazy var contentTextView        = UITextView(forExpandable: ())
    lazy var gridView               = GridView(forAutoLayout: ())

    private func configureTextView() {
        contentTextView.textContainerInset = UIEdgeInsets.zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.font = .systemFont(ofSize: 14)
        contentTextView.dataDetectorTypes = .link
        contentTextView.isUserInteractionEnabled = false
        contentTextView.delegate = self
    }

    // MARK: - Layout
    override func layoutContent() {
        configureTextView()

        contentView.addSubview(contentTextView)
        contentTextView.autoPinEdge(.top, to: .bottom, of: metaView, withOffset: 8)
        contentTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        contentTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)

        contentView.addSubview(gridView)
        centerConstraint = gridView.autoPinEdge(.top, to: .bottom, of: metaView, withOffset: 10)
        centerConstraint.isActive = false
        gridView.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 10)
        gridView.autoPinEdge(toSuperviewEdge: .left)
        gridView.autoPinEdge(toSuperviewEdge: .right)
        gridView.autoPinEdge(.bottom, to: .top, of: voteContainerView)
    }
    
    override func setUp(with post: ResponseAPIContentGetPost) {
        super.setUp(with: post)
        self.accessibilityLabel = "PostCardCell"
        centerConstraint.isActive = false

        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 21
        paragraph.maximumLineHeight = 21

        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraph
        ]

        var texts = NSMutableAttributedString()
        var paragraphsTexts: [NSAttributedString] = []
        for content in post.content ?? [] where content.type == "paragraph" {
            let attributedText = content.toAttributedString(currentAttributes: defaultAttributes, attachmentType: TextAttachment.self)
            texts.append(attributedText)
            paragraphsTexts.append(attributedText)
        }

        var moreTextAdded = false
        let moreText = NSAttributedString(string: "... \("See More".localized())", attributes: [.foregroundColor: UIColor.appMainColor, .font: UIFont.systemFont(ofSize: 14)])

        texts = NSMutableAttributedString(string: texts.string.replacingOccurrences(of: "\r", with: ""), attributes: defaultAttributes)

        if texts.length > 600 && !moreTextAdded {
            moreTextAdded = true
            texts = texts.attributedSubstring(from: NSRange(location: 0, length: 400)) as! NSMutableAttributedString
            texts.append(moreText)
        }

        if paragraphsTexts.count > 6 && !moreTextAdded {
            texts = NSMutableAttributedString()
            for (index, paragraph) in paragraphsTexts.enumerated() where index < 6 {
                texts.append(paragraph)
            }
            texts = NSMutableAttributedString(string: texts.string.replacingOccurrences(of: "\r", with: ""), attributes: defaultAttributes)
            texts.append(moreText)
        }

        // remove paragraph separator
        if texts.string.starts(with: "\n") {
            texts.deleteCharacters(in: NSRange(location: 0, length: 1))
        }

        if texts.length > 0 {
            contentTextView.attributedText = texts
        } else {
            centerConstraint.isActive = true
        }

//        if let content = post.content,
//            let firstSentence = content.first(where: {$0.type == "paragraph"}) {
//            let mutableAS = NSMutableAttributedString()
//            var attributedText = firstSentence
//                .toAttributedString(currentAttributes: defaultAttributes, attachmentType: TextAttachment.self)
//            if attributedText.length > 600 {
//                let moreText = NSAttributedString(string: "... \("See More".localized())", attributes: [.foregroundColor: UIColor.appMainColor, .font: UIFont.systemFont(ofSize: 14)])
//                attributedText = attributedText.attributedSubstring(from: NSRange(location: 0, length: 400))
//                mutableAS.append(moreText)
//            }
//            mutableAS.insert(attributedText, at: 0)
//
//            // check last charters a space
//            let spaceSymbols = "\n"
//            let components = mutableAS.components(separatedBy: spaceSymbols)
//            if let last = components.last, last.isEqual(to: NSAttributedString(string: "")) {
//                mutableAS.deleteCharacters(in: NSRange(location: mutableAS.length - spaceSymbols.count, length: spaceSymbols.count))
//            }
//
//            // remove paragraph separator
//            if mutableAS.string.starts(with: "\n\r") {
//                mutableAS.deleteCharacters(in: NSRange(location: 0, length: 2))
//            }
//
//            contentTextView.attributedText = mutableAS
//        } else {
//            centerConstraint.isActive = true
//        }

        contentTextView.resolveHashTags()
        contentTextView.resolveMentions()

        gridView.setUp(embeds: post.attachments)
    }
}

extension BasicPostCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        parentViewController?.present(safariVC, animated: true, completion: nil)
        return false
    }
}
