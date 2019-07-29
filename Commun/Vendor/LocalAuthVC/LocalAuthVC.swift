//
//  LocalAuthVC.swift
//  Commun
//
//  Created by Chung Tran on 7/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import THPinViewController
import CyberSwift
import RxSwift
import LocalAuthentication

class LocalAuthVC: THPinViewController {
    var canIgnore = false
    var remainingPinEntries = 3
    let didSuccess = PublishSubject<Bool>()
    
    init() {
        super.init(delegate: nil)
        delegate = self
    }
    
    deinit {
        didSuccess.onCompleted()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup views
        backgroundColor = .white
        promptColor = .black
        view.tintColor = .black
        promptTitle = "Enter passcode".localized()
        
        // face id, touch id button
        let button = UIButton(frame: .zero)
        let biometryType = LABiometryType.current
        button.setImage(biometryType.icon, for: .normal)
        leftBottomButton = button
        leftBottomButton?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        leftBottomButton?.widthAnchor.constraint(equalTo: leftBottomButton!.heightAnchor).isActive = true
        
        // Add cancel button on bottom
        if !canIgnore {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(cancelButtonDidTouch))
        }
    }
    
    @objc func cancelButtonDidTouch() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

extension LocalAuthVC: THPinViewControllerDelegate {
    func pinLength(for pinViewController: THPinViewController) -> UInt {
        return 4
    }
    
    func pinViewController(_ pinViewController: THPinViewController, isPinValid pin: String) -> Bool {
        guard let correctPin = Config.currentUser?.passcode else {return false}
        if pin == correctPin {return true}
        else {
            remainingPinEntries -= 1
            return false
        }
    }
    
    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        return remainingPinEntries > 0
    }
    
    func pinViewControllerDidDismiss(afterPinEntryWasSuccessful pinViewController: THPinViewController) {
        didSuccess.onNext(true)
    }
    
    func pinViewControllerDidDismiss(afterPinEntryWasUnsuccessful pinViewController: THPinViewController) {
        didSuccess.onNext(false)
    }
}
