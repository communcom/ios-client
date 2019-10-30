//
//  ArticleEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
        return Observable.combineLatest(
            titleTextView.rx.text.orEmpty,
            contentTextView.rx.text.orEmpty
        ).map {_ in ()}
    }
    
    override var isContentValid: Bool {
        let title = titleTextView.text ?? ""
        let content = contentTextView.text ?? ""
        
        // both title and content are not empty
        let titleAndContentAreNotEmpty = !title.isEmpty && !content.isEmpty
        
        // title is not beyond limit
        let titleIsInsideLimit =
            (title.count >= self.titleMinLettersLimit) &&
                (title.utf8.count <= self.titleBytesLimit)
        
        // content inside limit
        let contentInsideLimit = (content.count <= contentLettersLimit)
        
        // compare content
        var contentChanged = (title != viewModel.postForEdit?.document.attributes?.title)
        contentChanged = contentChanged || (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
        
        // reassign result
        return titleAndContentAreNotEmpty && titleIsInsideLimit && contentInsideLimit && contentChanged
    }
    
    override var postTitle: String? {
        self.titleTextView.text
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextView.becomeFirstResponder()
    }
    
    override func setUpViews() {
        super.setUpViews()
        titleTextViewCountLabel.isHidden = true
        
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.typingAttributes = [.font: UIFont.systemFont(ofSize: 21, weight: .bold)]
        titleTextView.placeholder = "title placeholder".localized().uppercaseFirst
        titleTextView.delegate = self
        
        contentTextView.layoutManager
            .ensureLayout(for: contentTextView.textContainer)
    }
    
    override func layoutTopContentTextView() {
        // title
        contentView.addSubview(titleTextView)
        titleTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        titleTextView.autoPinEdge(.top, to: .bottom, of: communityAvatarImage, withOffset: 20)
        
        // countLabel
        contentView.addSubview(titleTextViewCountLabel)
        titleTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: 8)
        titleTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        contentTextView.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: 28)
    }
    
    
    override func layoutBottomContentTextView() {
        contentTextView.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    override func setUp(with post: ResponseAPIContentGetPost) {
        self.titleTextView.rx.text.onNext(post.document.attributes?.title)
        super.setUp(with: post)
    }
    
    // MARK: - overriding actions
    override func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        _contentTextView.addImage(image, description: description)
    }
    
//    override func didAddImageFromURLString(_ urlString: String, description: String? = nil) {
//        _contentTextView.addImage(nil, urlString: urlString, description: description)
//    }
    
    override func didAddLink(_ urlString: String, placeholder: String? = nil) {
        _contentTextView.addLink(urlString, placeholder: placeholder)
    }
}
