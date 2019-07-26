//
//  CreatePinViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import THPinViewController
import CyberSwift

class SetPasscodeVC: THPinViewController, BoardingRouter {
    var currentPin: String?
    var completion: (()->Void)?
    var onBoarding = true
    var isVerifyVC = false
    
    init() {
        super.init(delegate: nil)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (currentPin == nil && onBoarding) {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
        clear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (currentPin == nil && onBoarding) {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup views
        backgroundColor = .white
        
        // cancel here means deleteButton
        disableCancel = false
        
        // Text
        if isVerifyVC {
            promptTitle = "Enter your current passcode".localized()
        } else {
            promptTitle = currentPin == nil ? "Create your passcode".localized() : "Verify your new passcode".localized()
        }
        
        promptColor = .black
        view.tintColor = .black
    }
}

extension SetPasscodeVC: THPinViewControllerDelegate {
    func pinLength(for pinViewController: THPinViewController) -> UInt {
        return 4
    }
    
    func pinViewController(_ pinViewController: THPinViewController, isPinValid pin: String) -> Bool {
        if currentPin == nil {
            let verifyVC = SetPasscodeVC()
            verifyVC.currentPin = pin
            verifyVC.completion = completion
            verifyVC.onBoarding = onBoarding
            show(verifyVC, sender: self)
            return true
        }
        if pin == currentPin {
            do {
                if !isVerifyVC {
                    try RestAPIManager.instance.rx.setPasscode(pin, onBoarding: onBoarding)
                }
                if let completion = completion {
                    completion()
                } else {
                    self.boardingNextStep()
                }
            } catch {
                self.showError(error)
                return false
            }
        }
        return pin == currentPin
    }
    
    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        return true
    }
}
