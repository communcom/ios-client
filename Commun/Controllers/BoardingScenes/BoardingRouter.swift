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
        
        #warning("add faceid/touch later")
        case .setFaceId, .backUpICloud:
            vc = controllerContainer.resolve(KeysVC.self)!
        case .setAvatar:
            vc = UIViewController()
        case .setBio:
            vc = UIViewController()
        default:
            return
        }
        
        navigationController?.pushViewController(vc)
    }
    
    func endBoarding() {
        try? KeychainManager.save(data: [
            Config.settingStepKey: CurrentUserSettingStep.completed.rawValue
        ])
    }
}
