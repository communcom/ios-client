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
                self.boldButton.isEnabled = false
                self.italicButton.isEnabled = false
                self.colorPickerButton.isEnabled = false
                self.addLinkButton.isEnabled = false
                self.photoPickerButton.isEnabled = false
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.didBeginEditing
            .subscribe(onNext: {_ in
                self.boldButton.isEnabled = true
                self.italicButton.isEnabled = true
                self.colorPickerButton.isEnabled = true
                self.addLinkButton.isEnabled = true
                self.photoPickerButton.isEnabled = true
                
                self.boldButton.isHidden = false
                self.italicButton.isHidden = false
                self.colorPickerButton.isHidden = false
                self.addLinkButton.isHidden = false
                self.photoPickerButton.isHidden = false
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.didEndEditing
            .subscribe(onNext: {
                self.boldButton.isHidden = true
                self.italicButton.isHidden = true
                self.colorPickerButton.isHidden = true
                self.addLinkButton.isHidden = true
                self.photoPickerButton.isHidden = true
            })
            .disposed(by: disposeBag)
        
        contentTextView.currentTextStyle
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
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.setDelegate(self)
        
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
            .drive(hideKeyboardButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // verification
        
        #warning("Verify community")
        #warning("fix contentText later")
        Observable.combineLatest(
                titleTextView.rx.text.orEmpty,
                contentTextView.rx.text.orEmpty
            )
            .map {
                // Text field  is not empty
                (!$0.0.isEmpty) && (!$0.1.isEmpty) &&
                // Title or content has changed
                ($0.0 != viewModel.postForEdit?.content.title ||
                $0.1 != viewModel.postForEdit?.content.body.preview)
            }
            .bind(to: sendPostButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
