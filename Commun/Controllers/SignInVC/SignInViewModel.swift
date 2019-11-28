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
import SwiftyJSON
import RxCocoa

typealias LoginCredential = (login: String, key: String)

class SignInViewModel {
    
    let qrCode = BehaviorRelay<LoginCredential>(value: (login: "", key: ""))
    
    func signIn(login: String, masterKey: String) -> Completable {
        return RestAPIManager.instance.login(login: login, masterKey: masterKey)
            .map {response -> String in
                guard response.permission == "active" else {throw ErrorAPI.unknown}
                return response.permission
            }
            .flatMapToCompletable()
            .observeOn(MainScheduler.instance)

        
        /*
        #warning("login with real logic")
        // Get test user
        let session = URLSession.shared
        return session.rx.json(url: URL(string: "http://116.203.39.126:7777/get_users")!)
            .flatMap {json -> Observable<(nickName: String, key: String)> in
                let users = JSON(json)
                guard let user = users.array?[0],
                    let username = user["username"].string,
                    let key = user["active_key"].string else {
                        throw ErrorAPI.requestFailed(message: "No test account founded")
                }
                print(username, key)
                return .just((nickName: username, key: key))
            }
            .flatMap {(nickName: String, key: String) -> Observable<String> in
                return NetworkService.shared.signIn(login: nickName, key: key)
                    .flatMap { (permission) -> Observable<String> in
                        if permission != "active" {throw SignInError.unknown}
                        UserDefaults.standard.set(true, forKey: Config.isCurrentUserLoggedKey)
                        return Observable<String>.just(permission)
                }
            }
            .observeOn(MainScheduler.instance)
        */
    }
}
