//
//  SocialLoginManager.swift
//  Commun
//
//  Created by Artem Shilin on 19/03/2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import RxSwift

enum SocialNetwork: String, CaseIterable {
    case facebook
    case google
}

protocol SocialLoginManager {
    var network: SocialNetwork { get }
    var viewController: UIViewController? { get set }
    func login() -> Single<String>
}

struct SocialIdentity: Decodable {
    let oauthState: String?
    let identity: String?
    let provider: String?
}

extension SocialLoginManager {
    func getIdentityFromToken(_ token: String) -> Single<SocialIdentity> {

        var baseURL = "https://dev-3.commun.com/oauth/"
        #if APPSTORE
        baseURL = "https://commun.com/oauth/"
        #endif

        let url = URL(string: "\(baseURL + network.rawValue)-token?access_token=\(token)")!
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .take(1)
            .asSingle()
            .map { data -> SocialIdentity in
                let identity = try JSONDecoder().decode(SocialIdentity.self, from: data)
                if identity.oauthState == "registered" {
                    throw CMError.registration(message: ErrorMessage.accountHasBeenRegistered.rawValue)
                }
                if identity.identity == nil {
                    throw CMError.registration(message: ErrorMessage.couldNotRetrieveUserIdentity.rawValue)
                }
                return identity
            }
            .observeOn(MainScheduler.instance)
    }
}

struct OpenSocialLink {
    static func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Open from FB app
        if ApplicationDelegate.shared.application(app, open: url, sourceApplication: nil, annotation: nil) {
            return true
        }

        let annotation = options[.annotation]
        guard let sourceApp = options[.sourceApplication] as? String else {
            return false
        }

        if GIDSignIn.sharedInstance()?.handle(url) ?? false {
            return true
        }

        if ApplicationDelegate.shared.application(app,
                                                  open: url,
                                                  sourceApplication: sourceApp,
                                                  annotation: annotation) {
            return true
        }

        return false
    }
}
