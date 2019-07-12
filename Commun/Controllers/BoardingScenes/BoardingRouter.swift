//
//  BoardingRouter.swift
//  Commun
//
//  Created by Chung Tran on 10/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

protocol BoardingRouter {}

extension BoardingRouter where Self: UIViewController {
    // MARK: - Flow
    func boardingNextStep() {
        let step = KeychainManager.currentUser()?.settingStep ?? .setPasscode
        
        var vc: UIViewController
        
        switch step {
        case .setPasscode:
            vc = SetPasscodeVC()
        case .setFaceId:
            vc = controllerContainer.resolve(EnableBiometricsVC.self)!
        case .backUpICloud:
            vc = controllerContainer.resolve(KeysVC.self)!
        case .setAvatar:
            vc = controllerContainer.resolve(PickupAvatarVC.self)!
        case .setBio:
            vc = controllerContainer.resolve(CreateBioVC.self)!
        default:
            return
        }
        
        navigationController?.pushViewController(vc)
    }
    
    func endBoarding() {
        try? KeychainManager.save(data: [
            Config.settingStepKey: CurrentUserSettingStep.completed.rawValue
        ])
        AppDelegate.reloadSubject.onNext(true)
    }
}
