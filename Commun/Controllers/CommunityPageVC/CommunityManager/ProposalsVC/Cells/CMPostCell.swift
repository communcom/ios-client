//
//  CMPostCell.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import SafariServices

class CMPostCell: MyTableViewCell {
    lazy var stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var metaView = PostMetaView(height: 40.0)
    
    lazy var contentTextView: UITextView = {
        let textView = UITextView(forExpandable: ())
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = .systemFont(ofSize: 14)
        textView.dataDetectorTypes = .link
        textView.isUserInteractionEnabled = false
        textView.delegate = self
        textView.backgroundColor = .clear
        return textView
    }()
    lazy var gridView = GridView(forAutoLayout: ())
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .appWhiteColor
        selectionStyle = .none
        accessibilityLabel = "PostCardCell"
        
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        setUpStackView()
    }
    
    func setUpStackView() {
        stackView.addArrangedSubviews([
            metaView,
            contentTextView,
            gridView
        ])
    }
    
    func setUp(post: ResponseAPIContentGetPost) {
        setUp(with: post.community, author: post.author, creationTime: post.meta.creationTime)
        setUp(with: post.content ?? [], attachments: post.attachments, isArticle: post.document?.attributes?.type == "article")
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity?, author: ResponseAPIContentGetProfile?, creationTime: String) {
        metaView.setUp(with: community, author: author, creationTime: creationTime)
    }
    
    func setUp(with content: [ResponseAPIContentBlock], attachments: [ResponseAPIContentBlock], isArticle: Bool = false) {
        if isArticle {
            contentTextView.isHidden = true
            gridView.isHidden = true
            fatalError("implementing")
        } else {
            contentTextView.isHidden = false
            gridView.isHidden = false
        }
    }
    
    func layoutForBasicPost(with content: [ResponseAPIContentBlock], attachments: [ResponseAPIContentBlock]) {
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
        
        for (index, content) in content.enumerated() where content.type == "paragraph" {
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
        
        if texts.length > 0 {
            contentTextView.attributedText = texts
        } else {
            contentTextView.isHidden = true
        }

        gridView.setUp(embeds: attachments)
    }
}

// MARK: - UITextViewDelegate
extension CMPostCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        parentViewController?.present(safariVC, animated: true, completion: nil)
        
        return false
    }
}
