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

class SetPasscodeVC: THPinViewController {

    // MARK: - Properties
    var currentPin: String?
    var completion: (() -> Void)?
    var onBoarding = true
    var isVerifyVC = false
    var needTransactionConfirmation: Bool!
    var error: NSError?

    lazy var buttonFaceID = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 50.0), height: CGFloat.adaptive(width: 50.0))))
    lazy var buttonTouchID = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 43.33), height: CGFloat.adaptive(width: 43.31))))
    lazy var context = LAContext()

    // MARK: - Class Initialization
    init(forTransactionConfirmation needTransactionConfirmation: Bool = false) {
        super.init(delegate: nil)
        self.needTransactionConfirmation = needTransactionConfirmation
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Class Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentPin == nil && onBoarding || needTransactionConfirmation {
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
        if currentPin == nil && onBoarding || needTransactionConfirmation {
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
        if needTransactionConfirmation {
            addActionButton()
            currentPin = Config.currentUser?.passcode
        }
        view.tintColor = .black
        modifyPromtTitle(asError: false)
    }

    // MARK: - Custom Functions
    private func addActionButton() {
        // Add Close button
        let closeButton = UIButton.circle(size: CGFloat.adaptive(width: 24.0), backgroundColor: #colorLiteral(red: 0.953, green: 0.961, blue: 0.98, alpha: 1), imageName: "icon-round-close-grey-default")
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView(inset: CGFloat.adaptive(height: 55.0), xInset: CGFloat.adaptive(width: 15.0))
        // Add Face/Touch ID button
        buttonFaceID.setImage(UIImage(named: "icon-face-id-grey-default"), for: .normal)
        buttonFaceID.addTarget(self, action: #selector(faceIdButtonTapped), for: .touchUpInside)
        buttonFaceID.isHidden = true
        buttonTouchID.setImage(UIImage(named: "icon-touch-id-grey-default"), for: .normal)
        buttonTouchID.addTarget(self, action: #selector(touchIdButtonTapped), for: .touchUpInside)
        buttonTouchID.isHidden = !isTouchIdEnable()
        let buttonsStackView = UIStackView(arrangedSubviews: [buttonFaceID, buttonTouchID], axis: .horizontal, spacing: 0.0, alignment: .center, distribution: .fill)
        view.addSubview(buttonsStackView)
        buttonsStackView.autoPinBottomAndTrailingToSuperView(inset: CGFloat.adaptive(height: 63.0), xInset: CGFloat.adaptive(width: 63.0))
    }

    private func didShowVerifyButton(_ value: Bool) {
        if needTransactionConfirmation {
            buttonTouchID.isHidden = !value
        }
    }

    private func modifyPromtTitle(asError isError: Bool) {
        switch needTransactionConfirmation {
        case true:
            if isError {
                promptTitle = "wrong code".localized().uppercaseFirst
                promptColor = #colorLiteral(red: 0.929, green: 0.173, blue: 0.357, alpha: 1)
            } else {
                promptTitle = "enter passcode".localized().uppercaseFirst
                promptColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            }
        default:
            if isError {
                // TODO: - ADD ERROR TEXT
            } else if isVerifyVC {
                promptTitle = "enter your current passcode".localized().uppercaseFirst
            } else {
                promptTitle = (currentPin == nil ? "create your passcode" : "verify your new passcode").localized().uppercaseFirst
                if currentPin != nil {
                    self.setNavBarBackButton()
                }
            }
            promptColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        }
    }

    private func isTouchIdEnable() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    // MARK: - Actions
    @objc func closeButtonTapped(_ sender: UIButton) {
        popToPreviousVC()
    }

    @objc func faceIdButtonTapped(_ sender: UIButton) {
        print("FaceID button tapped")
    }

    @objc func touchIdButtonTapped() {
        let reason = "identify yourself!".localized().uppercaseFirst
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                if success {
                    strongSelf.completion!()
                } else {
                    strongSelf.showError(authenticationError!)
                }
            }
        }
    }
}
// MARK: - THPinViewControllerDelegate
extension SetPasscodeVC: THPinViewControllerDelegate {
    func pinLength(for pinViewController: THPinViewController) -> UInt {
        return 4
    }

    func incorrectPinEntered(in pinViewController: THPinViewController) {
        modifyPromtTitle(asError: true)
    }

    func pinViewController(_ pinViewController: THPinViewController, didAddNumberToCurrentPin pin: String) {
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
                if needTransactionConfirmation {
                    completion!()
                } else if !isVerifyVC {
                    try RestAPIManager.instance.setPasscode(pin, onBoarding: onBoarding)
                    if let completion = completion {
                        completion()
                    }
                }
            } catch {
                self.showError(error)
                return false
            }
        }
        return pin == currentPin
    }

    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        didShowVerifyButton(true)
        return true
    }
}
