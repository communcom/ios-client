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
        // textView
        contentTextView.currentTextStyle
            .subscribe(onNext: { (textStyle) in
                self.boldButton.isSelected = textStyle.isBold
                self.italicButton.isSelected = textStyle.isItalic
                self.addLinkButton.isSelected = (textStyle.urlString != nil)
                self.colorPickerButton.backgroundColor = textStyle.textColor
            })
            .disposed(by: disposeBag)
        
        // isAdult
        adultButton.rx.tap
            .map {_ in !viewModel.isAdult.value}
            .bind(to: viewModel.isAdult)
            .disposed(by: disposeBag)
        
        viewModel.isAdult
            .map {$0 ? "18ButtonSelected": "18Button"}
            .map {UIImage(named: $0)}
            .bind(to: self.adultButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        // hideKeyboard
        UIResponder.keyboardHeightObservable
            .map {$0 == 0 ? true: false}
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] (hide) in
                self?.boldButton.isHidden = hide
                self?.italicButton.isHidden = hide
                self?.colorPickerButton.isHidden = hide
                self?.addLinkButton.isHidden = hide
                self?.hideKeyboardButton.isHidden = hide
            })
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
