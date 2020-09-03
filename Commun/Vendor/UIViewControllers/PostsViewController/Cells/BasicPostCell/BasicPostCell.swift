//
//  BasicPostCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

final class BasicPostCell: PostCell {
    // MARK: - Subviews
    lazy var contentStackView       = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var textStackView          = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var titleLabel             = UILabel.with(textSize: 18, weight: .semibold, numberOfLines: 0)
    lazy var contentTextView        = BasicPostCellTextView(forExpandable: ())
    lazy var gridView               = GridView(forAutoLayout: ())
    
    // MARK: - Layout
    override func layoutContent() {
        textStackView.addArrangedSubviews([
            titleLabel,
            contentTextView
        ])
        
        contentView.addSubview(contentStackView)
        contentStackView.autoPinEdge(.top, to: .bottom, of: metaView, withOffset: 8)
        contentStackView.autoPinEdge(toSuperviewEdge: .left)
        contentStackView.autoPinEdge(toSuperviewEdge: .right)
        contentStackView.autoPinEdge(.bottom, to: .top, of: postStatsView, withOffset: -10)
        
        contentStackView.addArrangedSubviews([
            textStackView.padding(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)),
            gridView
        ])
    }
    
    override func setUp(with post: ResponseAPIContentGetPost) {
        super.setUp(with: post)
        backgroundColor = .appWhiteColor
       
        self.accessibilityLabel = "PostCardCell"
        
        // title
        if let title = post.title, !title.isEmpty {
            titleLabel.isHidden = false
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 21
        paragraph.maximumLineHeight = 21

        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraph,
            .foregroundColor: UIColor.appBlackColor
        ]

        var texts = NSMutableAttributedString()
        var paragraphsTexts: [NSAttributedString] = []
        
        for (index, content) in (post.content ?? []).enumerated() where content.type == "paragraph" {
            let attributedText = content.toAttributedString(currentAttributes: defaultAttributes, attachmentType: TextAttachment.self, shouldAddParagraphSeparator: false)
            // remove empty text
            let text = attributedText.string
           
            if text != "", text != " " {
                if index != 0 {
                    texts.append(NSAttributedString(string: "\n", attributes: defaultAttributes))
                }
                
                texts.append(attributedText)
                paragraphsTexts.append(attributedText)
            }
        }

        var moreTextAdded = false
        let moreText = NSAttributedString(string: "... \("see".localized().uppercaseFirst + " " + "more".localized())", attributes: [.foregroundColor: UIColor.appMainColor, .font: UIFont.systemFont(ofSize: 14)])

        if texts.length > 600 && !moreTextAdded {
            moreTextAdded = true
            texts = texts.attributedSubstring(from: NSRange(location: 0, length: 400)) as! NSMutableAttributedString
            texts.append(moreText)
        }

        if paragraphsTexts.count > 6 && !moreTextAdded {
            texts = NSMutableAttributedString()
            for (index, paragraph) in paragraphsTexts.enumerated() where index < 6 {
                texts.append(paragraph)
                texts.append(NSAttributedString(string: "\n", attributes: defaultAttributes))
            }
            texts.append(moreText)
        }

        if texts.length > 0 {
            contentTextView.isHidden = false
            contentTextView.attributedText = texts
        } else {
            contentTextView.isHidden = true
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
