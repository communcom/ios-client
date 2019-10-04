//
//  EditorView+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorVC {
    func bindKeyboardHeight() {
        UIResponder.keyboardHeightObservable
            .map {$0 == 0 ? true: false}
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { (isHidden) in
                if isHidden {
                    self.removeTool(.hideKeyboard)
                }
                else {
                    self.insertTool(.hideKeyboard, at: 0)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindSendPostButton() {
        // Verification
        #warning("Verify community")
        contentCombined
            .map {_ in self.shouldSendPost}
            .bind(to: postButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
