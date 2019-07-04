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
import CyberSwift

class SetUserViewModel {
    // MARK: - Class Functions
    func checkUserName(_ userName: String) -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-")
        return !userName.isEmpty && userName.count <= 12 && userName.rangeOfCharacter(from: characterset.inverted) == nil
    }
    
    func setUser(userName: String, phone: String) -> Completable {
        return RestAPIManager.instance.rx.setUser(id: userName)
            .flatMapToCompletable()
    }
}
