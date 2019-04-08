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
    
    func makeSubscriptions() {
        viewModel?.isAdult.asObservable().subscribe(onNext: { [weak self] isAdult in
            self?.adultButton.setImage(isAdult ? UIImage(named: "18ButtonSelected") : UIImage(named: "18Button"), for: .normal)
        }).disposed(by: disposeBag)
        
    }
    
}
