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

enum SocialNetwork: String {
    case fb
    case google
}

protocol SocialLoginManagerDelegate: AnyObject {
    func successLogin(with social: SocialNetwork, token: String)
    func failedLogin(with social: SocialNetwork)
}

protocol SocialLoginManagerInput {
    var delegate: SocialLoginManagerDelegate? { get set }
    var viewController: UIViewController? { get set }
    func login()
}

struct SocialIdentity: Decodable {
    let oauthState: String?
    let identity: String?
    let provider: String?
}

class SocialLoginManager {
    func getIdentityFromToken(_ token: String, social: SocialNetwork, completion: @escaping (SocialIdentity?) -> Void) {

        var baseURL = "https://dev-3.commun.com/oauth/"
        #if APPSTORE
        baseURL = "https://commun.com/oauth/"
        #endif

        let url: URL!
        switch social {
        case .fb:
            url = URL(string: "\(baseURL)facebook-token?access_token=\(token)")!
        case .google:
            url = URL(string: "\(baseURL)google-token?access_token=\(token)")!
        }

        let task = URLSession.shared.dataTask(with: url) {(data, _, _) in
            guard let data = data else {
                completion(nil)
                return
            }

            guard let model = try? JSONDecoder().decode(SocialIdentity.self, from: data) else {
                completion(nil)
                return
            }

            completion(model)
        }

        task.resume()
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
