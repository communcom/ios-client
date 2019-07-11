//
//  BoardingVC.swift
//  Commun
//
//  Created by Chung Tran on 10/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class BoardingVC: UIViewController, BoardingRouter {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let step = KeychainManager.currentUser()?.settingStep,
            step != .setPasscode {
            boardingNextStep()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func setupPasscodeDidTouch(_ sender: Any) {
        boardingNextStep()
    }
}
