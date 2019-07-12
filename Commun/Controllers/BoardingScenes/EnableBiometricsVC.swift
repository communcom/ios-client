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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enableButton: StepButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // retrieve policy
        let context = LAContext()
        
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .touchID:
            imageView.image = UIImage(named: "boarding-touch-id")
            headerLabel.text = "Enable".localized() + " Touch Id"
            descriptionLabel.text = "Enable".localized() + " Touch Id " + "to secure your transactions".localized()
            enableButton.setTitle("Enable".localized() + " Touch Id", for: .normal)
            break
        case .faceID:
            imageView.image = UIImage(named: "boarding-face-id")
            headerLabel.text = "Enable".localized() + " Face Id"
            descriptionLabel.text = "Enable".localized() + " Face Id " + "to secure your transactions".localized()
            enableButton.setTitle("Enable".localized() + " Face Id", for: .normal)
            break
        default:
            try! KeychainManager.save(data: [
                Config.settingStepKey: CurrentUserSettingStep.backUpICloud.rawValue
            ])
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

    @IBAction func enableButtonDidTouch(_ sender: Any) {
        do {
            try KeychainManager.save(data: [
                Config.settingStepKey: CurrentUserSettingStep.backUpICloud.rawValue
            ])
            
            #warning("use string constant later")
            UserDefaults.standard.set(true, forKey: "isAuthenticationWithBiometricsEnabled")
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
