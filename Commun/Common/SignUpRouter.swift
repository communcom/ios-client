//
//  SignUpRouter.swift
//  Commun
//
//  Created by msm72 on 5/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

// MARK: - SignUpRoutingLogic protocol
@objc protocol SignUpRoutingLogic {
    func routeToSignInScene()
    func routeToSignUpNextScene()
}

class SignUpRouter: NSObject, SignUpRoutingLogic {
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    
    // MARK: - Class Initialization
    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    
    
    // MARK: - Routing
    func routeToSignInScene() {
        if  let signInVC = controllerContainer.resolve(SignInVC.self) {
            self.viewController?.navigationController?.pushViewController(signInVC)
            
            signInVC.handlerSignUp = { [weak self] success in
                guard let strongSelf = self else { return }
                
                if success {
                    strongSelf.routeToSignUpNextScene()
                }
            }
        }
    }
    
    func routeToSignUpNextScene() {
        guard let phone = UserDefaults.standard.string(forKey: Config.registrationUserPhoneKey), phone != "" else {
            self.viewController?.navigationController?.pushViewController(controllerContainer.resolve(SignUpVC.self)!)
            return
        }

        guard let json = KeychainManager.loadAllData(byUserPhone: phone), let state = json[Config.registrationStepKey] as? String else { return }
        
        switch state {
        // ConfirmUserVC
        case "verify":
            if  let confirmUserVC = controllerContainer.resolve(ConfirmUserVC.self), let smsCode = json[Config.registrationSmsCodeKey] as? UInt64 {
                confirmUserVC.viewModel = ConfirmUserViewModel(code: "\(smsCode)", phone: phone)
                let confirmUserNC = UINavigationController(rootViewController: confirmUserVC)
                self.viewController?.present(confirmUserNC, animated: true, completion: nil)
            }
            
        // SetUserVC
        case "setUsername":
            if let setUserVC = controllerContainer.resolve(SetUserVC.self) {
                setUserVC.viewModel = SetUserViewModel(phone: phone)
                self.viewController?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: .plain, target: nil, action: nil)
                self.viewController?.navigationController?.pushViewController(setUserVC)
            }

        // LoadKeysVC
        case "toBlockChain":
            DispatchQueue.main.async {
                if let loadKeysNC = controllerContainer.resolve(UINavigationController.self), let loadKeysVC = loadKeysNC.viewControllers.first as? LoadKeysVC, let nickName = json[Config.registrationUserIDKey] as? String {
                    loadKeysVC.viewModel = LoadKeysViewModel(nickName: nickName)
                    self.viewController?.present(loadKeysNC, animated: true, completion: nil)
                }
            }

        // SignUpVC
        default:
            self.viewController?.navigationController?.pushViewController(controllerContainer.resolve(SignUpVC.self)!)
        }
        
        self.viewController?.view.endEditing(true)
    }
}
