//
//  GoogleLoginManager.swift
//  Commun
//
//  Created by Artem Shilin on 19/03/2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import GoogleSignIn

class GoogleLoginManager: NSObject, SocialLoginManagerInput {
    weak var delegate: SocialLoginManagerDelegate?
    weak var viewController: UIViewController?

    private let manager = GIDSignIn.sharedInstance()

    override init() {
        super.init()
        manager?.delegate = self

        #if APPSTORE
        GIDSignIn.sharedInstance().clientID = "537042616174-n6ad5epkjq1dup8g3dsuqcnsqdlmgrc6.apps.googleusercontent.com"
        #else
        GIDSignIn.sharedInstance().clientID = "537042616174-temhloimlc21rtfkr2mrvojm912k2muk.apps.googleusercontent.com"
        #endif
    }

    func login() {
        manager?.presentingViewController = viewController
        manager?.signOut()
        manager?.signIn()
    }
}

extension GoogleLoginManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let token = user?.authentication.idToken else { return }
        self.delegate?.successLogin(with: .google, token: token)
    }

}
