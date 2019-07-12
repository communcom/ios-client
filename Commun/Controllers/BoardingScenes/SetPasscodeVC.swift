//
//  CreatePinViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import THPinViewController
import RxSwift
import CyberSwift

class SetPasscodeVC: THPinViewController, BoardingRouter {
    var currentPin: String?
    var pinSubject = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init() {
        super.init(delegate: nil)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (currentPin == nil) {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
        clear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (currentPin == nil) {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup views
        backgroundColor = .white
        disableCancel = true
        
        // Text
        promptTitle = currentPin == nil ? "Create your passcode".localized() : "Verify your new passcode".localized()
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
            show(verifyVC, sender: self)
            verifyVC.pinSubject
                .subscribe(onCompleted: {
                    verifyVC.navigationController?.popViewController(animated: true, {
                        do {
                            try RestAPIManager.instance.rx.setPasscode(pin)
                            self.boardingNextStep()
                        } catch {
                            self.showError(error)
                        }
                    })
                })
                .disposed(by: disposeBag)
            return true
        }
        if pin == currentPin {
            pinSubject.onCompleted()
        }
        return pin == currentPin
    }
    
    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        return true
    }
}
