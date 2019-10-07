//
//  BasicEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout
import RxCocoa
import RxSwift

class BasicEditorVC: EditorVC {
    // MARK: - Subviews
    var _contentTextView = BasicEditorTextView(height: 47.5)
    override var contentTextView: ContentTextView {
        return _contentTextView
    }
    var _contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    override var contentTextViewCharacterCountLabel: UILabel {
        return _contentTextViewCountLabel
    }
    
    // MARK: - Override
    override var contentCombined: Observable<Void> {
        return contentTextView.rx.text.orEmpty.map {_ in ()}
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.postForEdit == nil {
            appendTool(EditorToolbarItem.addArticle)
        }
    }
    
    override func layoutContentView() {
        super.layoutContentView()
        
        // textView
        contentView.addSubview(_contentTextView)
        _contentTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        _contentTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        _contentTextView.autoPinEdge(.top, to: .bottom, of: communityAvatarImage, withOffset: 20)
        
        // forward delegate
        _contentTextView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // countlabel
        contentView.addSubview(_contentTextViewCountLabel)
        _contentTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: _contentTextView, withOffset: -12)
        _contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
    }
    
    override func pinContentViewBottom() {
        _contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
    
    // MARK: - overriding actions
}
