//
//  CreatePinViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import THPinViewController
import CyberSwift

class SetPasscodeVC: THPinViewController {
    // MARK: - Properties
    var currentPin: String?
    var completion: (() -> Void)?
    var onBoarding = true
    var isVerifyVC = false
    
    
    // MARK: - Class Initialization
    init() {
        super.init(delegate: nil)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Class Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentPin == nil && onBoarding {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        } else {
            title = "passcode".localized().uppercaseFirst
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.layoutIfNeeded()
        }
     
        clear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        if currentPin == nil && onBoarding {
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
            promptTitle = "enter your current passcode".localized().uppercaseFirst
        } else {
            promptTitle = (currentPin == nil ? "create your passcode" : "verify your new passcode").localized().uppercaseFirst
        
            if currentPin != nil {
                self.setNavBarBackButton()
            }
        }
        
        promptColor = .black
        view.tintColor = .black
    }
}


// NARK: - THPinViewControllerDelegate
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
                    try RestAPIManager.instance.setPasscode(pin, onBoarding: onBoarding)
                }
                if let completion = completion {
                    completion()
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
    
//    func pinViewController(_ pinViewController: THPinViewController, didAddNumberToCurrentPin pin: String) { }
}
