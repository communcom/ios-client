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
    // MARK: - Subviews
    var _contentTextView = ArticleEditorTextView(forExpandable: ())
    override var contentTextView: ContentTextView {
        return _contentTextView
    }
    
    // MARK: - Properties
    var _viewModel = PostEditorViewModel()
    override var viewModel: PostEditorViewModel {
        return _viewModel
    }
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        contentTextView.layoutManager
            .ensureLayout(for: contentTextView.textContainer)
    }
}
