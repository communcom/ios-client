//
//  LoadKeysViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

class LoadKeysViewModel {
    // MARK: - Properties
    let nickname = BehaviorRelay<String>(value: "")
    
    
    // MARK: - Class Initialization
    init(nickName: String) {
        nickname.accept(nickName)
    }

    
    // MARK: - Class Functions
    func saveKeys() -> Observable<Bool> {
        return NetworkService.shared.saveKeys(nickName: nickname.value)
    }
}
