//
//  CreatePinViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
//  Apple recommends that you “Don’t reference Touch ID on a device that supports Face ID [and] don’t reference Face ID on a device that supports Touch ID”
//

import UIKit
import CyberSwift
import THPinViewController
import LocalAuthentication
import RxCocoa
import RxSwift

class ConfirmPasscodeVC: THPinViewController {
    // MARK: - Properties
    let currentPin: String = Config.currentUser?.passcode ?? "XXXX"
    let closeButton = UIButton.circle(size: CGFloat.adaptive(width: 24.0), backgroundColor: #colorLiteral(red: 0.953, green: 0.961, blue: 0.98, alpha: 1), imageName: "icon-round-close-grey-default")
    let touchFaceIdButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 50.0), height: CGFloat.adaptive(width: 50.0))))

    var error: NSError?
    var completion: (() -> Void)?
    let disposeBag = DisposeBag()
    lazy var context = LAContext()

    
    // MARK: - Class Initialization
    init() {
        super.init(delegate: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Class Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clear()
        addActionButtons()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableCancel = false
        view.tintColor = .black
        backgroundColor = .white
        modifyPromtTitle(asError: false)
        
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            showAlert(title: "info".localized().uppercaseFirst, message: "no biometry on your device".localized())
        }
    }
    
    // MARK: - Custom Functions
    private func addActionButtons() {
        // Add close button
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView(inset: CGFloat.adaptive(height: 15.0), xInset: CGFloat.adaptive(width: 15.0))
        
        // Add Touch/Face ID button
        let buttonImage = UIImage(named: context.biometryType == .faceID ? "icon-face-id-grey-default" : "icon-touch-id-grey-default" )
        touchFaceIdButton.setImage(buttonImage, for: .normal)
        touchFaceIdButton.addTarget(self, action: #selector(touchFaceIdButtonTapped), for: .touchUpInside)
        
        didShowVerifyButton(true)
        
        if let pinView = view.subviews.first as? THPinView, let pinNumPadView = pinView.subviews.first(where: { $0.isKind(of: THPinNumPadView.self )}),
            let deleteButton = pinView.subviews.first(where: { $0.isKind(of: UIButton.self )}) as? UIButton {
            pinNumPadView.addSubview(touchFaceIdButton)
            touchFaceIdButton.autoPinBottomAndTrailingToSuperView(inset: CGFloat.adaptive(height: 25.0 / 2), xInset: CGFloat.adaptive(width: 25.0 / 2))
                        
            deleteButton.rx.tap
                .bind {
                    self.didShowVerifyButton(deleteButton.isHidden)
            }
            .disposed(by: disposeBag)
        }
    }
    
    private func modifyPromtTitle(asError isError: Bool) {
        if isError {
            promptTitle = "wrong code".localized().uppercaseFirst
            promptColor = #colorLiteral(red: 0.929, green: 0.173, blue: 0.357, alpha: 1)
        } else {
            promptTitle = "enter passcode".localized().uppercaseFirst
            promptColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        }
        
        didShowVerifyButton(isError)
    }
    
    private func didShowVerifyButton(_ value: Bool) {
        touchFaceIdButton.isHidden = !(context.biometryType == .touchID || context.biometryType == .faceID && value)
    }
    
    private func verificationSuccessful() {
        completion!()
        closeButtonTapped(closeButton)
    }

    
    // MARK: - Actions
    @objc func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
     @objc func touchFaceIdButtonTapped(_ sender: UIButton) {
        guard error == nil else { return }
        
        let reason = "Identify yourself!"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
            guard let strongSelf = self else { return }
            
            if success {
                DispatchQueue.main.async {
                    strongSelf.verificationSuccessful()
                }
            } else {
                strongSelf.showError(authenticationError!)
            }
        }
    }
}


// NARK: - THPinViewDelegate
extension ConfirmPasscodeVC: THPinViewDelegate {
    func pinView(_ pinView: THPinView, isPinValid pin: String) -> Bool {
        return pin == currentPin
    }

    func pinLength(for pinView: THPinView) -> UInt {
        return 4
    }

    func cancelButtonTapped(in pinView: THPinView) {
    }

    func correctPinWasEntered(in pinView: THPinView) {
        verificationSuccessful()
    }

    func incorrectPinWasEntered(in pinView: THPinView) {
        modifyPromtTitle(asError: true)
    }

    func pinView(_ pinView: THPinView, didAddNumberToCurrentPin pin: String) {
        modifyPromtTitle(asError: false)
        didShowVerifyButton(pin.count == 0)
    }
}
