//
//  BoardingSetPasscodeVC.swift
//  Commun
//
//  Created by Chung Tran on 11/27/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class BoardingSetPasscodeVC: BoardingVC {
    // MARK: - Properties
    override var step: CurrentUserSettingStep {.setPasscode}
    override var nextStep: CurrentUserSettingStep? {.setFaceId}
    
    lazy var setPassCodeVC: SetPasscodeVC = {
        let vc = SetPasscodeVC()
        vc.completion = {
            self.next()
        }
        return vc
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        addChildViewController(setPassCodeVC, toContainerView: view)
        setPassCodeVC.view.frame = view.bounds
        setPassCodeVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
