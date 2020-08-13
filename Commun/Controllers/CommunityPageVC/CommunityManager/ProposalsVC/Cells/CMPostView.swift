//
//  CMPostCell.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import SafariServices

class CMPostView: MyView {
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
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(stackView)
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
            layoutForBasicPost(with: content, attachments: attachments)
        }
    }
    
    func layoutForBasicPost(with content: [ResponseAPIContentBlock], attachments: [ResponseAPIContentBlock]) {
        let texts = content.shortAttributedString
        
        if texts.length > 0 {
            contentTextView.attributedText = texts
            contentTextView.resolveHashTags()
            contentTextView.resolveMentions()
        } else {
            contentTextView.isHidden = true
        }

        gridView.setUp(embeds: attachments)
    }
}

// MARK: - UITextViewDelegate
extension CMPostView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        parentViewController?.present(safariVC, animated: true, completion: nil)
        
        return false
    }
}
