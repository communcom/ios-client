//
//  FBLoginManger.swift
//  Commun
//
//  Created by Artem Shilin on 19/03/2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FacebookLoginManager: NSObject, SocialLoginManagerInput {
    weak var viewController: UIViewController?
    weak var delegate: SocialLoginManagerDelegate?

    private let manager = LoginManager()
    private let permissons = ["public_profile"]

    override init() {
        super.init()
        Settings.appID = "150680096143077"
    }

    func login() {
        manager.logOut()
        manager.logIn(permissions: permissons, from: self.viewController) { [weak self] result, _ in
            guard let self = self else { return }
            if let token = result?.token?.tokenString {
                self.delegate?.successLogin(with: .fb, token: token)
            } else {
                self.delegate?.failedLogin(with: .fb)
            }
        }
    }

}
