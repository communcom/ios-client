//
//  BoardingVC.swift
//  Commun
//
//  Created by Chung Tran on 11/27/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class BoardingVC: BaseViewController {
    var step: CurrentUserSettingStep {fatalError("must override")}
    var nextStep: CurrentUserSettingStep? {fatalError("must override")}
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        if let step = KeychainManager.currentUser()?.settingStep,
            step != self.step {
            boardingNextStep()
        }
    }
    
    // MARK: - Flow
    func next() {
        if nextStep == nil {
            endBoarding()
            return
        }
        jumpTo(step: nextStep!)
    }
    
    private func jumpTo(step: CurrentUserSettingStep) {
        do {
            try KeychainManager.save([
                Config.settingStepKey: step.rawValue
            ])
            boardingNextStep()
        } catch {
            showError(error)
        }
    }
    
    private func boardingNextStep() {
        let step = KeychainManager.currentUser()?.settingStep ?? .setPasscode
        
        if KeychainManager.currentUser()?.registrationStep == .relogined {
            // skip all step after ftue
            if step == .ftue {
                endBoarding()
                return
            }
        }
        
        var vc: UIViewController
        
        switch step {
        case .setPasscode:
            vc = BoardingSetPasscodeVC()
        case .setFaceId:
            vc = EnableBiometricsVC()
        case .ftue:
            vc = FTUEVC()
        default:
            return
        }
        
        navigationController?.pushViewController(vc)
    }
    
    private func endBoarding() {
        try? KeychainManager.save([
            Config.settingStepKey: CurrentUserSettingStep.completed.rawValue
        ])
        AuthManager.shared.status.accept(.initializing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AuthManager.shared.status.accept(.authorized)
        }
    }
}
