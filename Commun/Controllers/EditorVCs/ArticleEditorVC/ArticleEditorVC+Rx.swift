//
//  EditorPageVC+Rx.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 08/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension ArticleEditorVC {
    func bindTitleTextView() {
        titleTextView.rx.didBeginEditing
            .subscribe(onNext: {_ in
                self.titleTextViewCharacterCountLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.didEndEditing
            .subscribe(onNext: {_ in
                self.titleTextViewCharacterCountLabel.isHidden =
                    self.titleTextViewCharacterCountLabel.textColor != .red
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.titleTextViewCharacterCountLabel.text = "\(text.utf8.count)/\(self.titleBytesLimit)"
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.text.orEmpty
            .map {$0.utf8.count > self.titleBytesLimit ? UIColor.red : UIColor.lightGray}
            .distinctUntilChanged()
            .subscribe(onNext: {color in
                self.titleTextViewCharacterCountLabel.textColor = color
            })
            .disposed(by: disposeBag)
    }
    
    func bindContentTextView() {
        contentTextView.rx.didBeginEditing
            .subscribe(onNext: {_ in
                self.boldButton.isHidden = false
                self.italicButton.isHidden = false
                self.colorPickerButton.isHidden = false
                self.addLinkButton.isHidden = false
                self.photoPickerButton.isHidden = false
                self.clearFormattingButton.isHidden = false
                self.contentTextViewCharacterCountLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.didEndEditing
            .subscribe(onNext: {
                self.boldButton.isHidden = true
                self.italicButton.isHidden = true
                self.colorPickerButton.isHidden = true
                self.addLinkButton.isHidden = true
                self.photoPickerButton.isHidden = true
                self.clearFormattingButton.isHidden = true
                self.contentTextViewCharacterCountLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.contentTextViewCharacterCountLabel.text = "\(text.count)/\(self.contentLettersLimit)"
            })
            .disposed(by: disposeBag)
        
        contentTextView.currentTextStyle
            .skip(1)
            .subscribe(onNext: { (textStyle) in
                // bold
                self.boldButton.isSelected = textStyle.isBold
                self.boldButton.isEnabled = (textStyle.urlString == nil)
                
                // italic
                self.italicButton.isSelected = textStyle.isItalic
                self.italicButton.isEnabled = (textStyle.urlString == nil)
                
                // add link button
                self.addLinkButton.isSelected = (textStyle.urlString != nil)
                
                // color picker
                self.colorPickerButton.backgroundColor = textStyle.textColor
                self.colorPickerButton.isEnabled = (textStyle.urlString == nil)
                
                // clear formatting
                let isDefaultFormat = !textStyle.isBold && !textStyle.isItalic && textStyle.textColor == .black && textStyle.urlString == nil
                let isMixed = textStyle.isMixed
                let canTouchClearFormattingButton = isMixed || !isDefaultFormat
                self.clearFormattingButton.isSelected = canTouchClearFormattingButton
                self.clearFormattingButton.isEnabled = canTouchClearFormattingButton
                
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}
