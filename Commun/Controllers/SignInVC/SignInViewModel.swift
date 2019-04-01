//
//  SignInViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 26/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class SignInViewModel {
    let disposeBag = DisposeBag()
    
    var errorSubject = PublishSubject<String>()
    
    func signIn(withLogin login: String, withApiKey key: String) {
        if checkCorrectUserData(login: login, key: key) {
            Config.currentUser.nickName = login
            Config.currentUser.activeKey = key
            NetworkService.shared.signIn().subscribe(onNext: { [weak self] permission in
                if permission == "active" {
                    UserDefaults.standard.set(true, forKey: "UserLoged")
                    self?.errorSubject.onCompleted()
                }
            }, onError: { [weak self] _ in
                    self?.errorSubject.onNext("Wrong Login and Key")
            }).disposed(by: disposeBag)
        } else {
            errorSubject.onNext("Wrong Login and Key")
        }
    }
    
    func checkCorrectUserData(login: String, key: String) -> Bool {
        return login.count > 3 && key.count > 10  // Надо узнать минимальное клличество символов.
    }
}
