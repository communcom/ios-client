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

extension EditorPageVC {
    
    func bindUI() {
        guard let viewModel = viewModel else {return}
        // textViews
        titleTextView.rx.didBeginEditing
            .subscribe(onNext: {_ in
                self.titleTextViewCharacterCountLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.didEndEditing
            .subscribe(onNext: {_ in
                self.titleTextViewCharacterCountLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.titleTextViewCharacterCountLabel.text = "\(text.count)/\(self.titleLettersLimit)"
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.text.orEmpty
            .filter {$0.count > self.titleLettersLimit}
            .subscribe(onNext: limitCharactersInTitle())
            .disposed(by: disposeBag)
        
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
        
        // isAdult
        adultButton.rx.tap
            .map {_ in !viewModel.isAdult.value}
            .bind(to: viewModel.isAdult)
            .disposed(by: disposeBag)
        
        viewModel.isAdult
            .bind(to: self.adultButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // hideKeyboard
        UIResponder.keyboardHeightObservable
            .map {$0 == 0 ? true: false}
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { (isHidden) in
                self.hideKeyboardButton.isHidden = isHidden
                self.editorToolsToContainerTrailingSpace.constant = isHidden ? 0 : 54
            })
            .disposed(by: disposeBag)
        
        // verification
        
        #warning("Verify community")
        #warning("fix contentText later")
        Observable.combineLatest(
                titleTextView.rx.text.orEmpty,
                contentTextView.rx.text.orEmpty
            )
            .map({ (title, content) -> Bool in
                // both title and content are not empty
                let titleAndContentAreNotEmpty = !title.isEmpty && !content.isEmpty
                
                // compare content
                var contentChanged = (title != viewModel.postForEdit?.content.title)
                contentChanged = contentChanged || (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
                
                // reassign result
                return titleAndContentAreNotEmpty && contentChanged
            })
            .bind(to: sendPostButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func limitCharactersInTitle() -> (_ newText: String) -> Void {
        return {newText in
            self.titleTextView.text =
                String(newText.prefix(self.titleLettersLimit))
        }
    }
}
