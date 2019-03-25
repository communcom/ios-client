//
//  PostPageVC+Rx.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

extension PostPageVC {
    
    func setupSubscriptions() {
        viewModel.post.asObservable().subscribe(onNext: { [weak self] _ in
            self?.makeCells()
        }).disposed(by: disposeBag)
        
        viewModel.comments.asObservable().subscribe(onNext: { [weak self] _ in
            self?.makeComments()
        }).disposed(by: disposeBag)
    }
    
}
