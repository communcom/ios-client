//
//  EnableBiometricsVC.swift
//  Commun
//
//  Created by Chung Tran on 12/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import LocalAuthentication

class EnableBiometricsVC: UIViewController, BoardingRouter {
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var enableButton: StepButton!

    @IBOutlet weak var headerLabel: UILabel! {
        didSet {
            self.headerLabel.tune(withText:             "Enable Touch ID title".localized(),
                                  hexColors:            blackWhiteColorPickers,
                                  font:                 UIFont.init(name: "SFProText-Semibold", size: 17.0 * Config.widthRatio),
                                  alignment:            .center,
                                  isMultiLines:         false)
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            self.descriptionLabel.tune(withText:        "Enable Touch ID description".localized(),
                                       hexColors:       darkGrayishBluePickers,
                                       font:            UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                       alignment:       .center,
                                       isMultiLines:    true)
        }
    }
    

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // retrieve policy
        let biometryType = LABiometryType.current
        
        if #available(iOS 11.2, *) {
            if biometryType == .none {
                try! KeychainManager.save(data: [
                    Config.settingStepKey: CurrentUserSettingStep.backUpICloud.rawValue
                    ])
                boardingNextStep()
                return
            }
        }
        
        imageView.image = biometryType.icon
        descriptionLabel.text = "Enable".localized() + " " + biometryType.stringValue + " " + "to secure your transactions".localized()
        enableButton.setTitle("Enable".localized() + " \(biometryType.stringValue)", for: .normal)
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
    @IBAction func enableButtonDidTouch(_ sender: Any) {
        do {
            try KeychainManager.save(data: [
                Config.settingStepKey: CurrentUserSettingStep.backUpICloud.rawValue
            ])
            
            UserDefaults.standard.set(true, forKey: Config.currentUserBiometryAuthEnabled)
            boardingNextStep()
        } catch {
            showError(error)
        }
    }
    
    @IBAction func skipButtonDidTouch(_ sender: Any) {
        do {
            try KeychainManager.save(data: [
                Config.settingStepKey: CurrentUserSettingStep.backUpICloud.rawValue
            ])
            boardingNextStep()
        } catch {
            showError(error)
        }
    }
}
