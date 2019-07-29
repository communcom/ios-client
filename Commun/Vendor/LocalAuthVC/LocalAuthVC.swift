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

class LocalAuthVC: THPinViewController {
    var canIgnore = false
    var cancelButton: UIButton?
    var remainingPinEntries = 3
    let didSuccess = PublishSubject<Bool>()
    
    init() {
        super.init(delegate: nil)
        delegate = self
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
        
        // Add cancel button on bottom
        if canIgnore {
            cancelButton = UIButton(frame: .zero)
            cancelButton?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(cancelButton!)
            cancelButton?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
            cancelButton?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            cancelButton?.setTitleColor(.black, for: .normal)
            cancelButton?.setTitle("Cancel".localized(), for: .normal)
            cancelButton?.addTarget(self, action: #selector(cancelButtonDidTouch), for: .touchUpInside)
        }
    }
    
    @objc func cancelButtonDidTouch() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
