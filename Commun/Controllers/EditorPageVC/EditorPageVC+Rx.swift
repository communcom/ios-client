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
        // isAdult
        viewModel.isAdult
            .map {$0 ? "18ButtonSelected": "18Button"}
            .map {UIImage(named: $0)}
            .bind(to: self.adultButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        // button state
        let titleContentCombined = Observable.combineLatest(titleTextField.rx.text.orEmpty, contentTextView.rx.text.orEmpty).share()
        
        #warning("Verify community")
        titleContentCombined.map {!$0.0.isEmpty && !$0.1.isEmpty}
            .bind(to: sendPostButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
}
