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
            vc = UIViewController()
        case .setAvatar:
            vc = UIViewController()
        case .setBio:
            vc = UIViewController()
        default:
            return
        }
        
        navigationController?.pushViewController(vc)
    }
}
