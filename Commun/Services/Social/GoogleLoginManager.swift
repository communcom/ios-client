//
//  GoogleLoginManager.swift
//  Commun
//
//  Created by Artem Shilin on 19/03/2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import GoogleSignIn
import RxSwift

class GoogleLoginManager: NSObject, SocialLoginManager {
    var network: SocialNetwork { .google }
    weak var viewController: UIViewController?

    private let manager = GIDSignIn.sharedInstance()
    
    private let subject = PublishSubject<(token: String?, error: Error?)>()
    
    override init() {
        super.init()
        manager?.delegate = self

        #if APPSTORE
        GIDSignIn.sharedInstance().clientID = "537042616174-n6ad5epkjq1dup8g3dsuqcnsqdlmgrc6.apps.googleusercontent.com"
        #else
        GIDSignIn.sharedInstance().clientID = "537042616174-temhloimlc21rtfkr2mrvojm912k2muk.apps.googleusercontent.com"
        #endif
    }

    func login() -> Single<String> {
        manager?.presentingViewController = viewController
        manager?.signOut()
        manager?.signIn()
        
        // listen
        return subject.take(1)
            .asSingle()
            .map { response -> String in
                if let error = response.error {throw error}
                return response.token!
            }
    }
}

extension GoogleLoginManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let token = user?.authentication.idToken else {
            subject.onNext((token: nil, error: error ?? CMError.registration(message: "could not retrieve token")))
            return
        }
        subject.onNext((token: token, error: nil))
    }
}
