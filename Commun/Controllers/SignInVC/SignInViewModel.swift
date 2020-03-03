//
//  SignInViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 26/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift
import SwiftyJSON
import RxCocoa

class SignInViewModel {
    func signIn(login: String, masterKey: String) -> Completable {
        return RestAPIManager.instance.login(login: login, masterKey: masterKey)
            .map {response -> String in
                guard response.permission == "active" else {throw CMError.unknown}
                return response.permission
            }
            .flatMapToCompletable()
            .observeOn(MainScheduler.instance)
    }
}
