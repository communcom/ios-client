//
//  ArticleEditorVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ArticleEditorVC {
    override func bind() {
        super.bind()
        // textViews
        bindTitleTextView()
    }
    
    func bindTitleTextView() {
        titleTextView.rx.didBeginEditing
            .subscribe(onNext: {_ in
                self.titleTextViewCountLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.didEndEditing
            .subscribe(onNext: {_ in
                self.titleTextViewCountLabel.isHidden =
                    self.titleTextViewCountLabel.textColor != .red
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.titleTextViewCountLabel.text = "\(text.utf8.count)/\(self.titleBytesLimit)"
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.text.orEmpty
            .map {$0.utf8.count > self.titleBytesLimit ? UIColor.red : UIColor.lightGray}
            .distinctUntilChanged()
            .subscribe(onNext: {color in
                self.titleTextViewCountLabel.textColor = color
            })
            .disposed(by: disposeBag)
    }
}
