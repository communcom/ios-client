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
    // MARK: - IBOutlets
    @IBOutlet weak var passcodeLabel: UILabel! {
        didSet {
            self.passcodeLabel.tune(withText:           "Set up Passcode".localized(),
                                    hexColors:          blackWhiteColorPickers,
                                    font:               UIFont.init(name: "SFProText-Semibold", size: 17.0 * Config.widthRatio),
                                    alignment:          .left,
                                    isMultiLines:       false)
        }
    }
    
    @IBOutlet weak var pincodeLabel: UILabel! {
        didSet {
            self.pincodeLabel.tune(withText:            "add short PIN code".localized().uppercaseFirst,
                                   hexColors:            grayWhiteColorPickers,
                                   font:                 UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                   alignment:            .left,
                                   isMultiLines:         true)
        }
    }
    
    
    // MARK: - Class Functions
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

    
    // MARK: - Actions
    @IBAction func setupPasscodeDidTouch(_ sender: Any) {
        boardingNextStep()
    }
}
