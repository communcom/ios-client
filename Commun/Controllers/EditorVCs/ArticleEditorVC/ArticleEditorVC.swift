//
//  ArticleEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class ArticleEditorVC: EditorVC {
    // MARK: - Constant
    let titleMinLettersLimit = 2
    let titleBytesLimit = 240
    let titleDraft = "EditorPageVC.titleDraft"
    
    // MARK: - Subviews
    var titleTextView = ExpandableTextView(height: 47.5)
    var titleTextViewCountLabel = UILabel.descriptionLabel("0/240")
    
    var _contentTextView = ArticleEditorTextView(height: 47.5)
    override var contentTextView: ContentTextView {
        return _contentTextView
    }
    
    // MARK: - Properties
    override var contentCombined: Observable<Void> {
        return Observable.combineLatest(
            titleTextView.rx.text.orEmpty,
            contentTextView.rx.text.orEmpty
        ).map {_ in ()}
    }
    
    override var shouldSendPost: Bool {
        let title = titleTextView.text ?? ""
    
        // title is not empty
        let titleIsNotEmpty = !title.isEmpty
        
        // title is not beyond limit
        let titleIsInsideLimit =
            (title.count >= self.titleMinLettersLimit) &&
                (title.utf8.count <= self.titleBytesLimit)
        
        // compare content
        let titleChanged = (title != viewModel.postForEdit?.content.title)
        
        // reassign result
        return super.shouldSendPost && titleIsNotEmpty && titleIsInsideLimit && titleChanged
    }
    
    // MARK: - Lifecycle
    override func setUpViews() {
        super.setUpViews()
        titleTextViewCountLabel.isHidden = true
        
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.typingAttributes = [.font: UIFont.systemFont(ofSize: 21, weight: .bold)]
        titleTextView.placeholder = "title placeholder".localized().uppercaseFirst
    }
    
    override func layoutTopContentTextView() {
        // title
        contentView.addSubview(titleTextView)
        titleTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        titleTextView.autoPinEdge(.top, to: .bottom, of: communityAvatarImage, withOffset: 20)
        
        // countLabel
        contentView.addSubview(titleTextViewCountLabel)
        titleTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: -12)
        titleTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        contentTextView.autoPinEdge(.top, to: .bottom, of: titleTextView)
    }
    
    
    override func layoutBottomContentTextView() {
        contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
    
    override func bind() {
        super.bind()
        // textViews
        bindTitleTextView()
    }
    
    override func setUp(with post: ResponseAPIContentGetPost) {
        self.titleTextView.rx.text.onNext(post.content.title)
        super.setUp(with: post)
    }
    
    // MARK: - overriding actions
    override func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        _contentTextView.addImage(image, description: description)
    }
    
    override func didAddImageFromURLString(_ urlString: String, description: String? = nil) {
        _contentTextView.addImage(nil, urlString: urlString, description: description)
    }
    
    override func didAddLink(_ urlString: String, placeholder: String? = nil) {
        _contentTextView.addLink(urlString, placeholder: description)
    }
    
    // MARK: - Draft
    override var hasDraft: Bool {
       return super.hasDraft && UserDefaults.standard.dictionaryRepresentation().keys.contains(titleDraft)
    }
    
    override func getDraft() {
       // get title
       titleTextView.text = UserDefaults.standard.string(forKey: titleDraft)
       super.getDraft()
    }

    override func saveDraft(completion: (()->Void)? = nil) {
       // save title
       UserDefaults.standard.set(titleTextView.text, forKey: titleDraft)
       super.saveDraft()
    }
    
    override func removeDraft() {
       UserDefaults.standard.removeObject(forKey: titleDraft)
       super.removeDraft()
    }
}
