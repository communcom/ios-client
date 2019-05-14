//
//  SetUserViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

class SetUserViewModel {
    // MARK: - Properties
    let userName = BehaviorRelay<String>(value: "")
    let phone = BehaviorRelay<String>(value: "")
    
    
    // MARK: - Class Initialization
    init(phone: String) {
        self.phone.accept(phone)
    }

    
    // MARK: - Class Functions
    func checkUserName() -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345.")
        return !self.userName.value.isEmpty && self.userName.value.count <= 12 && self.userName.value.rangeOfCharacter(from: characterset.inverted) == nil
    }
    
    func setUser() -> Observable<Bool> {
        return NetworkService.shared.setUser(name: userName.value, phone: phone.value).map({ result -> Bool in
            return result == "OK"
        })
    }
}
