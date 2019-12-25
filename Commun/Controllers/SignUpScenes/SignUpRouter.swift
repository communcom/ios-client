//
//  SignUpRouter.swift
//  Commun
//
//  Created by msm72 on 5/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
        case .verify:
            let confirmUserVC = controllerContainer.resolve(ConfirmUserVC.self)!
            vc = confirmUserVC
            
        case .setUserName, .toBlockChain:
            let setUserVC = SetUserVC()
            vc = setUserVC
            
        default:
            return
        }
        
        self.navigationController?.pushViewController(vc)
    }
    
    /// Reset signing up
    func resetSignUpProcess() {
        try? KeychainManager.deleteUser()
        // Dismiss all screen
        popToPreviousVC()
    }
}

extension SignUpRouter where Self: UIViewController {
    // MARK: - Back button
    func setBackButtonToSignUpVC() {
        let newBackButton = UIBarButtonItem(image: UIImage(named: "icon-back-bar-button-black-default"), style: .plain, target: self, action: #selector(popToPreviousVC))
        newBackButton.tintColor = .black
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = newBackButton
    }
}

extension SignUpRouter where Self: UIViewController {
    // MARK: - Handler
    func handleSignUpError(error: Error, with phone: String) {
        if let error = error as? ErrorAPI {
            switch error {
            case .registrationRequestFailed(let message, let currentStep):
                if message == "Invalid step taken" {
                    // save state
                    var dataToSave = [String: Any]()
                    dataToSave[Config.registrationUserPhoneKey] = phone
                    dataToSave[Config.registrationStepKey] = currentStep
                    do {
                        try KeychainManager.save(dataToSave)
                        hideHud()
                        signUpNextStep()
                    } catch {
                        hideHud()
                        showError(error)
                    }
                    return
                }
            default:
                break
            }
        }
        hideHud()
        showError(error)
    }
}
