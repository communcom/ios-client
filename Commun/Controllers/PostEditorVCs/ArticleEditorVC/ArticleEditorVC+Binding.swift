//
//  ArticleEditorVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ArticleEditorVC {
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
            .map {$0.utf8.count > self.titleBytesLimit ? UIColor.red : UIColor.e2e6e8}
            .distinctUntilChanged()
            .subscribe(onNext: {color in
                self.titleTextViewCountLabel.textColor = color
            })
            .disposed(by: disposeBag)
    }
    
    override func bindCommunity() {
        super.bindCommunity()
        viewModel.community
            .filter {$0 != nil}
            .subscribe(onNext: { _ in
                self.titleTextView.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}
