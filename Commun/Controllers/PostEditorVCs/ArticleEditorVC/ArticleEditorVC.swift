//
//  ArticleEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class ArticleEditorVC: PostEditorVC {
    // MARK: - Constant
    let titleMinLettersLimit = 2
    let titleBytesLimit = 240
    let titleDraft = "EditorPageVC.titleDraft"
    
    // MARK: - Subviews
    var titleTextView = UITextView(forExpandable: ())
    var titleTextViewCountLabel = UILabel.descriptionLabel("0/240")
    
    var _contentTextView = ArticleEditorTextView(forExpandable: ())
    override var contentTextView: ContentTextView {
        return _contentTextView
    }
    
    // MARK: - Properties
    var _viewModel = PostEditorViewModel()
    override var viewModel: PostEditorViewModel {
        return _viewModel
    }
    
    override var contentCombined: Observable<Void> {
        return Observable.merge(
            super.contentCombined,
            titleTextView.rx.text.orEmpty.map {_ in ()},
            contentTextView.rx.text.orEmpty.map {_ in ()}
        )
    }
    
    override var isContentValid: Bool {
        hintType = nil
        
        let title = titleTextView.text.trimmed
        let content = contentTextView.text.trimmed
        
        // both title and content are not empty
        let titleAndContentAreNotEmpty = !title.isEmpty && !content.isEmpty
        if !titleAndContentAreNotEmpty {hintType = .error("title and content must not be empty".localized().uppercaseFirst)}
        
        // title is not beyond limit
        let titleIsInsideLimit =
            (title.count >= self.titleMinLettersLimit) &&
                (title.utf8.count <= self.titleBytesLimit)
        if !titleIsInsideLimit {hintType = .error("title must less than \(titleMinLettersLimit) characters".localized().uppercaseFirst)}
        
        // content inside limit
        let contentInsideLimit = (content.count <= contentLettersLimit)

        if !contentInsideLimit {
            hintType = .error(String(format: "%@ %i %@", "content must less than".localized().uppercaseFirst, contentLettersLimit, "characters".localized()))
        }
        
        // compare content
        var contentChanged = (title != viewModel.postForEdit?.document?.attributes?.title)
        contentChanged = contentChanged || (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
        if !contentChanged {hintType = .error("content wasn't changed".localized().uppercaseFirst)}
        
        // reassign result
        return super.isContentValid && titleAndContentAreNotEmpty && titleIsInsideLimit && contentInsideLimit && contentChanged
    }
    
    override var postTitle: String? {
        self.titleTextView.text
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setUp() {
        super.setUp()
        titleTextViewCountLabel.isHidden = true
        
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.typingAttributes = [.font: UIFont.systemFont(ofSize: 21, weight: .bold)]
        titleTextView.placeholder = "title placeholder".localized().uppercaseFirst
        titleTextView.delegate = self
        
        contentTextView.layoutManager
            .ensureLayout(for: contentTextView.textContainer)
    }
    
    override func bind() {
        super.bind()
        // textViews
        bindTitleTextView()
    }
    
    override func layoutTopContentTextView() {
        // title
        contentView.addSubview(titleTextView)
        titleTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        titleTextView.autoPinEdge(.top, to: .bottom, of: communityView, withOffset: 5)
        
        // countLabel
        contentView.addSubview(titleTextViewCountLabel)
        titleTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: 8)
        titleTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        contentTextView.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: 28)
    }
    
    override func layoutBottomContentTextView() {
        contentTextView.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    override func setUp(with post: ResponseAPIContentGetPost) -> Completable {
        self.titleTextView.rx.text.onNext(post.document?.attributes?.title)
        return super.setUp(with: post)
    }
}
