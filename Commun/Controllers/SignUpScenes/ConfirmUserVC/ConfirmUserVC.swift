//
//  ConfirmUserVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

// FIXME: Need Refactoring

import UIKit
import RxSwift
import RxCocoa
import CyberSwift
import PinCodeInputView

class ConfirmUserVC: UIViewController, SignUpRouter {
    static let numberOfDigits = 4

    // MARK: - Properties
    let disposeBag = DisposeBag()

    var resendTimer: Timer?
    var resendSeconds: Int = 0
    static var counter: Int = 0

    let pinCodeInputView: PinCodeInputView<ItemView> = .init(digit: numberOfDigits,
            itemSpacing: 12,
            itemFactory: {
                let itemView = ItemView()
                let autoTestMarker = String(format: "ConfirmUserPinCodeInputView-%i", counter)

                // For autotest
                itemView.accessibilityLabel = autoTestMarker
                itemView.accessibilityIdentifier = autoTestMarker
                counter += 1

                return itemView
            })

    // MARK: - IBOutlets
    @IBOutlet weak var pinCodeView: UIView!

    @IBOutlet weak var securityCodeTextField: UITextField! {
        didSet {
            if #available(iOS 12.0, *) {
                self.securityCodeTextField.textContentType = .oneTimeCode
                self.securityCodeTextField.delegate = self
                self.securityCodeTextField.tag = 777
            }
        }
    }

    @IBOutlet weak var smsCodeLabel: UILabel! {
        didSet {
            self.smsCodeLabel.tune(withText: "enter sms-code".localized().uppercaseFirst,
                                   textColor: .black,
                                   font: UIFont.systemFont(ofSize: .adaptive(width: 17), weight: .regular),
                                   alignment: .center,
                                   isMultiLines: false)
        }
    }

    @IBOutlet weak var resendButton: ResendButton! {
        didSet {
            self.resendButton.isEnabled = true

            self.resendButton.tune(withTitle: "resend verification code".localized().uppercaseFirst,
                                   textColor: .appMainColor,
                                   font: UIFont.systemFont(ofSize: .adaptive(width: 15), weight: .semibold),
                                   alignment: .center)
        }
    }

    @IBOutlet weak var resendTimerLabel: UILabel! {
        didSet {
            self.resendTimerLabel.tune(withText: "",
                                       textColor: .appMainColor,
                                       font: UIFont.systemFont(ofSize: .adaptive(width: 15), weight: .semibold),
                                       alignment: .center,
                                       isMultiLines: false)

            self.checkResendSmsCodeTime()
        }
    }

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsManger.shared.registrationOpenScreen(3)
        self.title = "verification".localized().uppercaseFirst
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.setNavBarBackButton(title: "close")

        self.pinCodeInputView.set(changeTextHandler: { _ in
            self.verify()
        })

        self.pinCodeInputView.set(appearance: .init(itemSize: CGSize(width: .adaptive(width: 48.0), height: .adaptive(height: 56.0)),
                font: UIFont.systemFont(ofSize: .adaptive(width: 26), weight: .regular),
                textColor: .black,
                backgroundColor: UIColor(hexString: "F3F5FA")!,
                cursorColor: UIColor(red: 69 / 255, green: 108 / 255, blue: 1, alpha: 1),
                cornerRadius: .adaptive(height: 8.0)
        ))

        self.pinCodeView.addSubview(pinCodeInputView)
        self.pinCodeInputView.center = pinCodeView.center
    }

    override func viewWillLayoutSubviews() {
        self.pinCodeInputView.frame = CGRect(origin: .zero, size: CGSize(width: 228.0 * Config.widthRatio, height: 56.0 * Config.heightRatio))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.securityCodeTextField.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.deleteCode()
        self.pinCodeInputView.resignFirstResponder()
    }

    // MARK: - Custom Functions
    func checkResendSmsCodeTime() {
        guard let user = KeychainManager.currentUser(),
              user.registrationStep == .verify,
              let date = user.smsNextRetry
                else {
            self.resendButton.isEnabled = true
            self.resendTimerLabel.isHidden = true
            return
        }

        self.resendButton.isEnabled = false
        self.resendTimerLabel.isHidden = false

        let dateNextSmsRetry = date.convert(toDateFormat: .nextSmsDateType)
        self.resendSeconds = Date().seconds(date: dateNextSmsRetry)

        // Run timer
        self.resendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }

    func addAccessoryView(withSmsCode smsCode: String) {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: .adaptive(height: 44.0)))
        let smsCodeButton = UIBarButtonItem(title: smsCode, style: .plain, target: self, action: #selector(smsCodeButtonTapped(button:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [spacer, smsCodeButton, spacer]
        toolBar.tintColor = UIColor(hexString: "#6A80F5")
        self.securityCodeTextField.inputAccessoryView = toolBar
    }

    func removeAccessoryView() {
        self.securityCodeTextField.inputAccessoryView = nil
    }

    // MARK: - Gestures
    @IBAction func handlerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: - Actions
    @objc func smsCodeButtonTapped(button: UIBarButtonItem) {
        self.pinCodeInputView.insertText(button.title!)
        removeAccessoryView()
    }

    @objc func onTimerFires() {
        guard self.resendSeconds > 1 else {
            self.resendTimer?.invalidate()
            self.resendTimer = nil
            self.resendTimerLabel.text = nil
            self.resendButton.isEnabled = true
            self.resendTimerLabel.isHidden = true
            return
        }

        self.resendSeconds -= 1
        self.resendTimerLabel.text = "0:\(String(describing: self.resendSeconds).addFirstZero())"
    }

    @IBAction func resendButtonTapped(_ sender: UIButton) {
        guard KeychainManager.currentUser()?.phoneNumber != nil else {
            try? KeychainManager.deleteUser()
            // Go back
            popToPreviousVC()
            return
        }
        AnalyticsManger.shared.smsCodeResend()

        RestAPIManager.instance.resendSmsCode()
                .subscribe(onSuccess: { [weak self] (_) in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.checkResendSmsCodeTime()
                        self.showAlert(title: "info".localized().uppercaseFirst,
                                       message: "successfully resend code".localized().uppercaseFirst)
                    }
                }) { [weak self] (error) in
                    self?.showError(error)
                }
                .disposed(by: disposeBag)
    }

    func verify() {
        guard pinCodeInputView.text.count == ConfirmUserVC.numberOfDigits,
            let code = UInt64(pinCodeInputView.text) else {
                return
        }
        AnalyticsManger.shared.smsCodeEntered()

        showIndetermineHudWithMessage("verifying...".localized().uppercaseFirst)

        RestAPIManager.instance.verify(code: code)
            .subscribe(onSuccess: { [weak self] (_) in
                AnalyticsManger.shared.smsCodeRight()
                self?.hideHud()
                self?.signUpNextStep()
            }) { (error) in
                self.deleteCode()
                AnalyticsManger.shared.smsCodeError()
                self.hideHud()
                self.handleSignUpError(error: error)
            }
            .disposed(by: disposeBag)
    }

    func deleteCode() {
        for _ in 0..<ConfirmUserVC.numberOfDigits {
            pinCodeInputView.deleteBackward()
        }
    }
}

class ResendButton: UIButton {
     override var isEnabled: Bool {
         didSet {
            self.backgroundColor = self.isEnabled ? #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1) : #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 0.3834813784)
            self.alpha = 1.0
            self.backgroundColor = self.isEnabled ? .appMainColor : .appGrayColor
         }
     }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        self.backgroundColor = .clear
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)

        // Localize label
        if let text = titleLabel?.text {
            setTitle(text.localized().uppercaseFirst, for: .normal)
            setTitleColor(.white, for: .normal)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ConfirmUserVC: UITextFieldDelegate {
    // TextField become first responder
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }

    // // TextField resign first responder
    func textFieldDidEndEditing(_ textField: UITextField) {
    }

    // Add validation to TextField
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    // Clear button tap
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }

    // Hide keyboard
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    // TextField editing
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 777 {
            self.pinCodeInputView.insertText(string)
        }

        return true
    }

    // Return button tap
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
