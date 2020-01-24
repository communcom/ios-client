//
//  CreatePinViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
    let buttonsView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 50.0), height: CGFloat.adaptive(width: 50.0))))
    let closeButton = UIButton.circle(size: CGFloat.adaptive(width: 24.0), backgroundColor: #colorLiteral(red: 0.953, green: 0.961, blue: 0.98, alpha: 1), imageName: "icon-round-close-grey-default")
    let buttonFaceID = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 50.0), height: CGFloat.adaptive(width: 50.0))))
    let buttonTouchID = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 50.0), height: CGFloat.adaptive(width: 50.0))))
    var deleteButton: UIButton = UIButton()
    
    var error: NSError?
    var completion: (() -> Void)?
    let disposeBag = DisposeBag()
    lazy var context = LAContext()

    
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
    }
    
    // MARK: - Custom Functions
    private func addActionButtons() {
        // Add close button
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView(inset: CGFloat.adaptive(height: 15.0), xInset: CGFloat.adaptive(width: 15.0))
        
        // Add Face/Touch ID button
        buttonFaceID.setImage(UIImage(named: "icon-face-id-grey-default"), for: .normal)
        buttonFaceID.addTarget(self, action: #selector(faceIdButtonTapped), for: .touchUpInside)
        
        buttonTouchID.setImage(UIImage(named: "icon-touch-id-grey-default"), for: .normal)
        buttonTouchID.addTarget(self, action: #selector(touchIdButtonTapped), for: .touchUpInside)
        
        didShowVerifyButton(true)
        
        if let pinView = view.subviews.first as? THPinView, let pinNumPadView = pinView.subviews.first(where: { $0.isKind(of: THPinNumPadView.self )}),
            let deleteButton = pinView.subviews.first(where: { $0.isKind(of: UIButton.self )}) as? UIButton {
            let buttonsStackView = UIStackView(arrangedSubviews: [buttonFaceID, buttonTouchID], axis: .horizontal, spacing: 0.0, alignment: .fill, distribution: .fill)
            buttonsView.addSubview(buttonsStackView)
            buttonsStackView.autoPinEdgesToSuperviewEdges()
            
            pinNumPadView.addSubview(buttonsView)
            buttonsView.autoPinBottomAndTrailingToSuperView(inset: CGFloat.adaptive(height: 25.0 / 2), xInset: CGFloat.adaptive(width: 25.0 / 2))
            
            self.deleteButton = deleteButton
            
            self.deleteButton.rx.tap
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
        buttonsView.isHidden = !value
        buttonFaceID.isHidden = false
        buttonTouchID.isHidden = !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    private func verificationSuccessful() {
        completion!()
        closeButtonTapped(closeButton)
    }

    
    // MARK: - Actions
    @objc func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func faceIdButtonTapped(_ sender: UIButton) {
        print("FaceID button tapped")
    }

     @objc func touchIdButtonTapped(_ sender: UIButton) {
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


//// NARK: - THPinViewDelegate
//extension ConfirmPasscodeVC: THPinViewDelegate {
//    func pinView(_ pinView: THPinView, isPinValid pin: String) -> Bool {
//        modifyPromtTitle(asError: false)
//        didShowVerifyButton(deleteButton.isHidden)
//        return pin == currentPin
//    }
//
//    func pinLength(for pinView: THPinView) -> UInt {
//        return 4
//    }
//
//    func cancelButtonTapped(in pinView: THPinView) {
//    }
//
//    func correctPinWasEntered(in pinView: THPinView) {
//        verificationSuccessful()
//    }
//
//    func incorrectPinWasEntered(in pinView: THPinView) {
//        modifyPromtTitle(asError: true)
//    }
//
//    func pinView(_ pinView: THPinView, didAddNumberToCurrentPin pin: String) {
//        modifyPromtTitle(asError: false)
//        didShowVerifyButton(pin.count == 0)
//    }
//}


// MARK: - THPinViewControllerDelegate
extension ConfirmPasscodeVC: THPinViewControllerDelegate {
    func pinLength(for pinViewController: THPinViewController) -> UInt {
        return 4
    }

    func incorrectPinEntered(in pinViewController: THPinViewController) {
        modifyPromtTitle(asError: true)
    }

    func pinViewController(_ pinViewController: THPinViewController, isPinValid pin: String) -> Bool {
        modifyPromtTitle(asError: false)
        didShowVerifyButton(deleteButton.isHidden)
        
        return pin == currentPin
    }

    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        return true
    }

    func pinViewController(_ pinViewController: THPinViewController, didAddNumberToCurrentPin pin: String) {
        print("XXX")
    }
}
