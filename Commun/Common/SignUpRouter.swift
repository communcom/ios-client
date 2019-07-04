//
//  SignUpRouter.swift
//  Commun
//
//  Created by msm72 on 5/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

protocol SignUpRouter {}

extension SignUpRouter where Self: UIViewController {
    func endSigningUp() {
        // Save keys
        UserDefaults.standard.set(true, forKey: Config.isCurrentUserLoggedKey)
        WebSocketManager.instance.authorized.accept(true)
    }
    
    func resetSignUpProcess() {
        try! KeychainManager.deleteUser()
        // Dismiss all screen
        view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
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
        let signUpVC = controllerContainer.resolve(SignUpVC.self)!
        
        // Retrieve current user's state
        guard let user = KeychainManager.currentUser() else {
            // Navigate to SignUpVC if no user exists
            showOrPresentVC(signUpVC)
            return
        }
        
        // Retrieve step
        guard let step = user.registrationStep else {
            Logger.log(message: "Invalid registrationStep: \(user.registrationStep.debugDescription)", event: .error)
            resetSignUpProcess()
            return
        }
        
        // Navigation
        var vc: UIViewController
        
        switch step {
        case .verify:
            guard let confirmUserVC = controllerContainer.resolve(ConfirmUserVC.self),
                let smsCode = user.smsCode,
                let phone = user.phoneNumber
                else {
                    Logger.log(message: "Invalid parameters for confirmUserVC with user: \(user)", event: .error)
                    resetSignUpProcess()
                    return
            }
            
            confirmUserVC.viewModel = ConfirmUserViewModel(code: "\(smsCode)", phone: phone)
            
            vc = confirmUserVC
            
        case .setUserName:
            guard let setUserVC = controllerContainer.resolve(SetUserVC.self),
                let _ = user.phoneNumber
                else {
                    Logger.log(message: "Invalid parameters for setUserVC with user: \(user)", event: .error)
                    resetSignUpProcess()
                    return
            }
            vc = setUserVC
            
        case .toBlockChain:
            let loadKeysVC = controllerContainer.resolve(LoadKeysVC.self)!
            loadKeysVC.viewModel = LoadKeysViewModel()
            vc = loadKeysVC
        default:
            vc = signUpVC
        }
        
        showOrPresentVC(vc)
    }
    
    private func showOrPresentVC(_ vc: UIViewController) {
        if let nc = self.navigationController {
            nc.pushViewController(vc)
            return
        }
        
        present(vc, animated: true, completion: nil)
    }
}
