//
//  LoadKeysViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoadKeysViewModel {
    
    let nickname = BehaviorRelay<String>(value: "")
    
    init(nickName: String) {
        nickname.accept(nickName)
    }
    
    func saveKeys() -> Observable<Bool> {
        return NetworkService.shared.saveKeys(nickName: nickname.value)
    }
    
}
