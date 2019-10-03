//
//  EditorPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 29/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift
import RxCocoa

class ArticleEditorVC: CommonEditorVC {
    // MARK: - Constant
    let titleMinLettersLimit = 2
    let titleBytesLimit = 240
    let titleDraft = "EditorPageVC.titleDraft"
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextView: ExpandableTextView!
    @IBOutlet weak var titleTextViewCharacterCountLabel: UILabel!
    @IBOutlet weak var contentTextView: EditorPageTextView!
    
    // MARK: - Properties
    override var contentCombined: Observable<[Any]>! {
        return Observable.combineLatest(
            titleTextView.rx.text.orEmpty,
            contentTextView.rx.text.orEmpty
        ).map {[$0, $1]}
    }
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        titleTextViewCharacterCountLabel.isHidden = true
        titleLabel.text = (viewModel?.postForEdit != nil ? "edit post" : "create post").localized().uppercaseFirst
        
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.placeholder = "title placeholder".localized().uppercaseFirst
        
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        // you should ensure layout
        contentTextView.layoutManager
            .ensureLayout(for: contentTextView.textContainer)
        
        // if editing post
        if let post = viewModel?.postForEdit {
            showIndetermineHudWithMessage("loading post".localized().uppercaseFirst)
            // Get full post
            NetworkService.shared.getPost(withPermLink: post.contentId.permlink, forUser: post.contentId.userId)
                .do(onSuccess: { (post) in
                    if post.content.body.full == nil {
                        throw ErrorAPI.responseUnsuccessful(message: "Content not found")
                    }
                })
                .subscribe(onSuccess: {post in
                    self.hideHud()
                    self.titleTextView.rx.text.onNext(post.content.title)
                    self.contentTextView.parseText(post.content.body.full!)
                    self.viewModel?.postForEdit = post
                }, onError: {error in
                    self.hideHud()
                    self.showError(error)
                    self.closeButtonDidTouch(self)
                })
                .disposed(by: disposeBag)
        }
        else {
            // parse draft
            if hasDraft {
                showAlert(
                    title: "retrieve draft".localized().uppercaseFirst,
                    message: "you have a draft version on your device".localized().uppercaseFirst + ". " + "continue editing it".localized().uppercaseFirst + "?",
                    buttonTitles: ["OK".localized(), "cancel".localized().uppercaseFirst],
                    highlightedButtonIndex: 0) { (index) in
                        if index == 0 {
                            self.getDraft()
                        }
                        else if index == 1 {
                            self.removeDraft()
                        }
                }
            }
        }
    }
    
    override func bindUI() {
        super.bindUI()
        
        // textViews
        bindTitleTextView()
        bindContentTextView()
    }
    
    override func verify() -> Bool {
        guard let viewModel = viewModel else {return false}
        let title = titleTextView.text ?? ""
        let content = contentTextView.text ?? ""
    
        // both title and content are not empty
        let titleAndContentAreNotEmpty = !title.isEmpty && !content.isEmpty
        
        // title is not beyond limit
        let titleIsInsideLimit =
            (title.count >= self.titleMinLettersLimit) &&
                (title.utf8.count <= self.titleBytesLimit)
        
        // compare content
        var contentChanged = (title != viewModel.postForEdit?.content.title)
        contentChanged = contentChanged || (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
        
        // reassign result
        return titleAndContentAreNotEmpty && titleIsInsideLimit && contentChanged
    }
}
