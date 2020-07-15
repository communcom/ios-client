//
//  AppleLoginManager.swift
//  Commun
//
//  Created by Artem Shilin on 07.07.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import RxSwift
import Foundation
import AuthenticationServices

class AppleLoginManager: NSObject, SocialLoginManager {
    var network: SocialNetwork { .apple }
    var viewController: UIViewController?

    private let subject = PublishSubject<String>()

    func login() -> Single<String> {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
        return subject.take(1).asSingle()
    }
}

extension AppleLoginManager: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.authorizationCode,
            let token = String(data: tokenData, encoding: .utf8)
        else { return }

        subject.onNext(token)
    }
}
