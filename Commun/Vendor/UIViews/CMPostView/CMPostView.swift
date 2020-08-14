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
    
    lazy var headerView = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
    lazy var metaView = PostMetaView(height: 40.0)
    
    lazy var contentTextViewWrapper: UIView = {
        let view = UIView(forAutoLayout: ())
        view.addSubview(contentTextView)
        contentTextView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        return view
    }()
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
    
    lazy var articleCardViewWrapper: UIView = {
        let view = UIView(forAutoLayout: ())
        view.addSubview(articleCardView)
        articleCardView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        return view
    }()
    lazy var articleCardView = ArticleCardView(forAutoLayout: ())
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        setUpHeaderView()
        setUpStackView()
    }
    
    private func setUpHeaderView() {
        headerView.addArrangedSubviews([
            UIView.spacer(),
            metaView,
            UIView.spacer()
        ])
    }
    
    func setUpStackView() {
        stackView.addArrangedSubviews([
            headerView,
            contentTextViewWrapper,
            gridView,
            articleCardViewWrapper
        ])
    }
    
    func setUp(post: ResponseAPIContentGetPost) {
        metaView.setUp(post: post)
        
        let isArticle = post.document?.attributes?.type == "article"
        
        contentTextViewWrapper.isHidden = isArticle
        gridView.isHidden = isArticle
        articleCardViewWrapper.isHidden = !isArticle
        if isArticle {
            articleCardView.setUp(with: post)
        } else {
            let texts = (post.content ?? []).shortAttributedString
            
            if texts.length > 0 {
                contentTextView.attributedText = texts
                contentTextView.resolveHashTags()
                contentTextView.resolveMentions()
            } else {
                contentTextViewWrapper.isHidden = true
            }

            gridView.setUp(embeds: post.attachments)
        }
    }
    
    func setUp(comment: ResponseAPIContentGetComment) {
        articleCardViewWrapper.isHidden = true
        metaView.setUp(comment: comment)
        let texts = (comment.content ?? []).shortAttributedString
        if texts.length > 0 {
            contentTextView.attributedText = texts
            contentTextView.resolveHashTags()
            contentTextView.resolveMentions()
        } else {
            contentTextViewWrapper.isHidden = true
        }
        gridView.setUp(embeds: comment.attachments)
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
