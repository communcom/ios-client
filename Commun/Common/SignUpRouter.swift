//
//  SignUpRouter.swift
//  Commun
//
//  Created by msm72 on 5/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift

protocol SignUpRouter {
    var disposeBag: DisposeBag {get}
}

extension SignUpRouter where Self: UIViewController {
    
    /// End signing up
    func endSigningUp() {
        // Save keys
        do {
            try KeychainManager.save(data: [
                Config.registrationStepKey: CurrentUserRegistrationStep.registered.rawValue
            ])
            UserDefaults.standard.set(true, forKey: Config.isCurrentUserLoggedKey)
            WebSocketManager.instance.authorized.accept(true)
        } catch {
            showError(error)
        }
        
    }
    
    /// Reset signing up
    func resetSignUpProcess() {
        try? KeychainManager.deleteUser()
        // Dismiss all screen
        view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    /// Move to sign in
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
    
    /// Move to next scene
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
            let confirmUserVC = controllerContainer.resolve(ConfirmUserVC.self)!
            confirmUserVC.viewModel = ConfirmUserViewModel()!
            vc = confirmUserVC
            
        case .setUserName:
            let setUserVC = controllerContainer.resolve(SetUserVC.self)!
            vc = setUserVC
            
        case .toBlockChain:
            let loadKeysVC = controllerContainer.resolve(LoadKeysVC.self)!
            loadKeysVC.viewModel = LoadKeysViewModel()
            vc = loadKeysVC
            
        case .setAvatar:
            let pickAvatarVC = controllerContainer.resolve(PickupAvatarVC.self)!
            vc = pickAvatarVC
            
        case .setBio:
            let createBioVC = controllerContainer.resolve(CreateBioVC.self)!
            vc = createBioVC
            
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

extension SignUpRouter where Self: UIViewController {
    // MARK: - Handler
    func handleSignUpError(error: Error, with phone: String) {
        if let error = error as? ErrorAPI {
            if error.caseInfo.message == "Invalid step taken" {
                handleInvalidStepTakenWithPhone(phone)
                return
            }
        }
        self.showError(error)
    }
    
    /// handle Invalid step taken
    func handleInvalidStepTakenWithPhone(_ phone: String) {
        do {
            try KeychainManager.save(data: [
                Config.registrationUserPhoneKey: phone
            ])
            
            // Get state
            RestAPIManager.instance.rx.getState()
                .subscribe(onSuccess: { (result) in
                    // save state to keychain
                    var dataToSave = [
                        Config.registrationStepKey: result.currentState
                    ]
                    
                    // user (for toBlockChain step)
                    if let user = result.user {
                        dataToSave[Config.currentUserIDKey] = user
                    }
                    
                    // save data
                    do {
                        try KeychainManager.save(data: dataToSave)
                        
                        // move to next screen
                        self.signUpNextStep()
                    } catch {
                        self.showError(error)
                    }
                    
                }) { (error) in
                    self.showError(error)
                }
                .disposed(by: disposeBag)
        } catch {
            showError(error)
        }
    }
}
