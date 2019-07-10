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
    // MARK: - Flow
    /// Move to next scene
    func signUpNextStep() {
        // Retrieve current user's state
        let user = KeychainManager.currentUser()
        let step = user?.registrationStep ?? .firstStep
        
        // Navigation
        var vc: UIViewController
        
        switch step {
        case .firstStep:
            return
            
        case .verify:
            let confirmUserVC = controllerContainer.resolve(ConfirmUserVC.self)!
            confirmUserVC.viewModel = ConfirmUserViewModel()!
            vc = confirmUserVC
            
        case .setUserName:
            let setUserVC = controllerContainer.resolve(SetUserVC.self)!
            vc = setUserVC
            
        case .toBlockChain:
            return
            
        case .setPasscode:
            let setPasscode = SetPasscodeVC(delegate: nil)
            vc = setPasscode
            
        case .setFaceId:
            vc = UIViewController()
            
        case .backUpICloud:
            vc = UIViewController()
            
        case .setAvatar:
            let pickAvatarVC = controllerContainer.resolve(PickupAvatarVC.self)!
            vc = pickAvatarVC
            
        case .setBio:
            let createBioVC = controllerContainer.resolve(CreateBioVC.self)!
            vc = createBioVC
            
        case .registered:
            endSigningUp()
            return
        }
        
        self.navigationController?.pushViewController(vc)
    }
    
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
        popToSignUpVC()
    }
}

extension SignUpRouter where Self: UIViewController {
    // MARK: - Back button
    func setBackButtonToSignUpVC() {
        navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back".localized(), style: .plain, target: self, action: #selector(popToSignUpVC))
        navigationItem.leftBarButtonItem = newBackButton
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
        // Get state
        RestAPIManager.instance.rx.getState(phone: phone)
            .subscribe(onSuccess: { (result) in
                if result.currentState == "registered" {
                    self.showErrorWithLocalizedMessage("This number is already taken!")
                    return
                }
                self.signUpNextStep()
            }) { (error) in
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
