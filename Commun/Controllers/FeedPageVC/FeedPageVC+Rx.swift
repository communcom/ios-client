//
//  FeedPageVC+Rx.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwifterSwift

extension FeedPageVC {
    
    func makeSubscriptions() {
        viewModel.errors.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "Ошибка", message: error.localizedDescription)
        }).disposed(by: disposeBag)
        
        viewModel.items.asObservable().subscribe(onNext: { [weak self] items in
            self?.makeCells()
        }).disposed(by: disposeBag)
    }
    
}
