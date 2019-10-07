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
    
    // MARK: - Lifecycle
    override func layoutTopContentTextView() {
        // title
        contentView.addSubview(titleTextView)
        titleTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        titleTextView.autoPinEdge(.top, to: .bottom, of: communityAvatarImage, withOffset: 20)
        
        // forward delegate
        titleTextView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // countLabel
        contentView.addSubview(titleTextViewCountLabel)
        titleTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: -12)
        titleTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        contentTextView.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: 20)
    }
    
    
    override func layoutBottomContentTextView() {
        contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
    
//    // MARK: - Draft
//    override var hasDraft: Bool {
//       return super.hasDraft && titleTextView.hasDraft
//    }
//
//    override func saveDraft(completion: (()->Void)? = nil) {
//       // save title
//       UserDefaults.standard.set(titleTextView.text, forKey: titleDraft)
//       super.saveDraft()
//    }
//
//    override func getDraft() {
//       // get title
//       titleTextView.text = UserDefaults.standard.string(forKey: titleDraft)
//       super.getDraft()
//    }
//
//    override func removeDraft() {
//       UserDefaults.standard.removeObject(forKey: titleDraft)
//       super.removeDraft()
//    }
}
