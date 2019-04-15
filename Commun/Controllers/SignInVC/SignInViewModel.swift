//
//  SignInViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 26/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class SignInViewModel {
    enum SignInError: Error {
        case unknown
    }
    
    func signIn(withLogin login: String, withApiKey key: String) -> Observable<String> {
        #warning("login with real logic")
        return NetworkService.shared.signIn(login: Config.accountNickTest, key: Config.activeKeyTest)
            .flatMap { (permission) -> Observable<String> in
                if permission != "active" {throw SignInError.unknown}
                UserDefaults.standard.set(true, forKey: "UserLoged")
                return Observable<String>.just(permission)
            }
    }
}
