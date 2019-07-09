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
        // scrollView
        scrollView.rx.willDragDown
            .filter {$0}
            .subscribe(onNext: {_ in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        // image
        let imageViewIsEmpty = imageView.rx.isEmpty.share()
        
        imageViewIsEmpty
            .map {$0 ? 0: self.imageView.size.width * (self.imageView.image!.size.height / self.imageView.image!.size.width)}
            .bind(to: imageViewHeightConstraint.rx.constant)
            .disposed(by: disposeBag)
        
        imageViewIsEmpty
            .map {$0 ? 0: 24}
            .bind(to: removeImageButtonHeightConstraint.rx.constant)
            .disposed(by: disposeBag)
        
        imageViewIsEmpty
            .filter {!$0}
            .subscribe(onNext: {_ in
                self.scrollView.scrollsToBottom()
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
        
        // verification
        
        #warning("Verify community")
        #warning("fix contentText later")
        imageViewIsEmpty
            .subscribe(onNext: { (empty) in
                self.viewModel?.imageChanged.accept(true)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
                titleTextView.rx.text.orEmpty,
                contentTextView.rx.text.orEmpty,
                viewModel.imageChanged.map {_ in ""}
            )
            .map {
                // Text field  is not empty
                (!$0.0.isEmpty) && (!$0.1.isEmpty) &&
                // Title or content has changed
                ($0.0 != viewModel.postForEdit?.content.title ||
                $0.1 != viewModel.postForEdit?.content.body.preview ||
                    self.viewModel?.imageChanged.value == true)
            }
            .bind(to: sendPostButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
}
