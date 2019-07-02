//
//  SignUpRouter.swift
//  Commun
//
//  Created by msm72 on 5/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

protocol SignUpRouter {
    func signUpNextStep()
}

extension SignUpRouter where Self: UIViewController {
    func routeToSignInScene() {
        let signInVC = controllerContainer.resolve(SignInViewController.self)!
        
        signInVC.handlerSignUp = { [weak self] success in
            guard let strongSelf = self else { return }
            
            if success {
                strongSelf.signUpNextStep()
            }
        }
        
        navigationController?.pushViewController(signInVC)
    }
    
    
    func signUpNextStep() {
        // Retrieve current user's state
        guard let user = KeychainManager.currentUser() else {
            Logger.log(message: "Invalid user: \(KeychainManager.currentUser().debugDescription)", event: .error)
            return
        }
        
        // Retrieve step
        guard let step = user.registrationStep else {
            Logger.log(message: "Invalid registrationStep: \(user.registrationStep.debugDescription)", event: .error)
            return
        }
        
        // Navigation
        switch step {
        case "verify":
            guard let confirmUserVC = controllerContainer.resolve(ConfirmUserVC.self),
                let smsCode = user.smsCode,
                let phone = user.phoneNumber
            else {
                Logger.log(message: "Invalid parameters for confirmUserVC with user: \(user)", event: .error)
                return
            }
            
            confirmUserVC.viewModel = ConfirmUserViewModel(code: "\(smsCode)", phone: phone)
            let confirmUserNC = UINavigationController(rootViewController: confirmUserVC)
            present(confirmUserNC, animated: true, completion: nil)
            
        case "setUsername":
            guard let setUserVC = controllerContainer.resolve(SetUserVC.self),
                let phone = user.phoneNumber
            else {
                Logger.log(message: "Invalid parameters for setUserVC with user: \(user)", event: .error)
                return
            }
            
            setUserVC.viewModel = SetUserViewModel(phone: phone)
            
            if let nc = self.navigationController {
                nc.pushViewController(setUserVC)
                return
            }
            
            present(setUserVC, animated: true, completion: nil)
            
        case "toBlockChain":
            let loadKeysNC = controllerContainer.resolve(UINavigationController.self)!
            let loadKeysVC = loadKeysNC.viewControllers.first as! LoadKeysVC
            
            loadKeysVC.viewModel = LoadKeysViewModel(nickName: user.id)
            present(loadKeysNC, animated: true, completion: nil)
            
        default:
            navigationController?.pushViewController(controllerContainer.resolve(SignUpVC.self)!)
        }
    }
}
