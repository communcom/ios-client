//
//  EditorView+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostEditorVC {
    func bindKeyboardHeight() {
        UIResponder.keyboardHeightObservable
            .map {$0 == 0 ? true: false}
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { (isHidden) in
                if isHidden {
                    self.removeTool(.hideKeyboard)
                } else {
                    self.insertTool(.hideKeyboard, at: 0)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindSendPostButton() {
        // Verification
        contentCombined
            .map {_ in self.isContentValid}
            .bind(to: actionButton.rx.isDisabled)
            .disposed(by: disposeBag)
    }
    
    @objc func bindContentTextView() {
        contentTextView.rx.didBeginEditing
            .subscribe(onNext: {[unowned self] _ in
//                self.appendTool(.setBold)
//                self.appendTool(.setItalic)
//                self.appendTool(.setColor)
//                self.appendTool(.addLink)
//                self.appendTool(.clearFormatting)
                //TODO: change color
                self.contentTextViewCountLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.didEndEditing
            .subscribe(onNext: {
//                self.removeTool(.setBold)
//                self.removeTool(.setItalic)
//                self.removeTool(.setColor)
//                self.removeTool(.addLink)
//                self.removeTool(.clearFormatting)
                self.contentTextViewCountLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.contentTextViewCountLabel.text = "\(text.count)/\(self.contentLettersLimit)"
            })
            .disposed(by: disposeBag)
        
        contentTextView.currentTextStyle
            .skip(1)
            .subscribe(onNext: { (textStyle) in
                // bold
                self.toggleIsHighlightedForTool(.setBold, isHighlighted: textStyle.isBold)
                self.toggleIsEnabledForTool(.setBold, isEnabled: (textStyle.urlString == nil))
                
                // italic
                self.toggleIsHighlightedForTool(.setItalic, isHighlighted: textStyle.isItalic)
                self.toggleIsEnabledForTool(.setItalic, isEnabled: (textStyle.urlString == nil))
                
                // add link button
//                self.toggleIsEnabledForTool(.addLink, isEnabled: (textStyle.urlString != nil))
                
                // color picker
                self.setOtherOptionForTool(.setColor, value: textStyle.textColor)
                self.toggleIsEnabledForTool(.setColor, isEnabled: (textStyle.urlString == nil))
                
                // clear formatting
                let isDefaultFormat = !textStyle.isBold && !textStyle.isItalic && textStyle.textColor == .black && textStyle.urlString == nil
                let isMixed = textStyle.isMixed
                let canTouchClearFormattingButton = isMixed || !isDefaultFormat
                
                self.toggleIsHighlightedForTool(.clearFormatting, isHighlighted: canTouchClearFormattingButton)
                self.toggleIsEnabledForTool(.clearFormatting, isEnabled: canTouchClearFormattingButton)
                
            })
            .disposed(by: disposeBag)
    }
    
    @objc func bindCommunity() {
        viewModel.community
            .subscribe(onNext: { (community) in
                self.youWillPostInLabel.isHidden = false
                
                if community?.communityId == "FEED" {
                    self.youWillPostInLabel.isHidden = true
                    self.communityAvatarImage.setToCurrentUserAvatar()
                    self.communityNameLabel.text = "my feed".localized().uppercaseFirst
                    self.communityNameLabel.textColor = .black
                    return
                }
                if let community = community {
                    self.communityAvatarImage.setAvatar(urlString: community.avatarUrl, namePlaceHolder: community.name)
                    self.communityNameLabel.text = community.name
                    self.communityNameLabel.textColor = .black
                } else {
                    self.communityAvatarImage.removeAvatar()
                    self.communityNameLabel.text = "hint type choose community".localized().uppercaseFirst
                    self.communityNameLabel.textColor = .a5a7bd
                }
            })
            .disposed(by: disposeBag)
    }
}
