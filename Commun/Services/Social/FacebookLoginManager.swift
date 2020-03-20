//
//  FBLoginManger.swift
//  Commun
//
//  Created by Artem Shilin on 19/03/2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import RxSwift

class FacebookLoginManager: NSObject, SocialLoginManager {
    var network: SocialNetwork { .facebook }
    
    weak var viewController: UIViewController?

    private let manager = LoginManager()
    private let permissons = ["public_profile"]

    override init() {
        super.init()
        Settings.appID = "150680096143077"
    }
    
    func login() -> Single<String> {
        Single<String>.create {single in
            self.manager.logOut()
            self.manager.logIn(permissions: self.permissons, from: self.viewController) { (result, error) in
                if let token = result?.token?.tokenString {
                    single(.success(token))
                    return
                }
                single(.error(error ?? CMError.registration(message: "could not retrieve token")))
            }
            return Disposables.create {}
        }
    }

}
