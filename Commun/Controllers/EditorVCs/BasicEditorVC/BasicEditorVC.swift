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
    
    override func layoutTopContentTextView() {
        contentTextView.autoPinEdge(.top, to: .bottom, of: communityAvatarImage, withOffset: 20)
    }
    
    override func layoutBottomContentTextView() {
        contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
    
    // MARK: - overriding actions
    override func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        // TODO: - Add embeds
    }
    
    override func didAddImageFromURLString(_ urlString: String, description: String? = nil) {
        // TODO: - Add embeds
    }
    
    override func didAddLink(_ urlString: String, placeholder: String? = nil) {
        // TODO: - Add link
    }
}
