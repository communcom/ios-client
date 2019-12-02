//
//  ConfirmUserVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
    
    let pinCodeInputView: PinCodeInputView<ItemView> = .init(digit:         numberOfDigits,
                                                             itemSpacing:   12,
                                                             itemFactory:   {
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
    
    @IBOutlet weak var smsCodeLabel: UILabel! {
        didSet {
            self.smsCodeLabel.tune(withText:      "enter sms-code".localized().uppercaseFirst,
                                   hexColors:     blackWhiteColorPickers,
                                   font:          UIFont(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                   alignment:     .center,
                                   isMultiLines:  false)
        }
    }
    @IBOutlet weak var nextButton: StepButton!
    
    @IBOutlet weak var resendButton: ResendButton! {
        didSet {
            self.resendButton.isEnabled = true
            
            self.resendButton.tune(withTitle:     "resend verification code".localized().uppercaseFirst,
                                   hexColors:     [softBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers],
                                   font:          UIFont(name: "SFProText-Semibold", size: 15.0 * Config.widthRatio),
                                   alignment:     .center)
        }
    }

    @IBOutlet weak var resendTimerLabel: UILabel! {
        didSet {
            self.resendTimerLabel.tune(withText:      "",
                                       hexColors:     verySoftBlueColorPickers,
                                       font:          UIFont(name: "SFProText-Semibold", size: 15.0 * Config.widthRatio),
                                       alignment:     .center,
                                       isMultiLines:  false)
            
            self.checkResendSmsCodeTime()
        }
    }
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "verification".localized().uppercaseFirst
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.setNavBarBackButton(title: "close")

        nextButton.isEnabled = false

        self.pinCodeInputView.set(changeTextHandler: { text in
            self.verify()
        })
        
        self.pinCodeInputView.set(appearance: .init(itemSize:         CGSize(width: 48.0 * Config.widthRatio, height: 56.0 * Config.heightRatio),
                                                    font:             .init(descriptor:     UIFontDescriptor(name:  "SFProText-Regular",
                                                                                                             size:  26.0 * Config.widthRatio),
                                                                            size:           26.0 * Config.heightRatio),
                                                    textColor:        .black,
                                                    backgroundColor:  UIColor(hexString: "F3F5FA")!,
                                                    cursorColor:      UIColor(red: 69/255, green: 108/255, blue: 1, alpha: 1),
                                                    cornerRadius:     8.0 * Config.heightRatio
            )
        )
        
        self.pinCodeView.addSubview(pinCodeInputView)
        self.pinCodeInputView.center = pinCodeView.center
    }
    
    override func viewWillLayoutSubviews() {
        self.pinCodeInputView.frame = CGRect(origin: .zero, size: CGSize(width: 228.0 * Config.widthRatio, height: 56.0 * Config.heightRatio))
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
        
        let dateNextSmsRetry    =   date.convert(toDateFormat: .nextSmsDateType)
        self.resendSeconds      =   Date().seconds(date: dateNextSmsRetry)
        
        // Run timer
        self.resendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    
    // MARK: - Gestures
    @IBAction func handlerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    // MARK: - Actions
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
                resetSignUpProcess()
                return
        }
        
        RestAPIManager.instance.resendSmsCode()
            .subscribe(onSuccess: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.showAlert(title:         "info".localized().uppercaseFirst,
                                     message:       "successfully resend code".localized().uppercaseFirst,
                                     completion:    { success in
                                        strongSelf.checkResendSmsCodeTime()
                })
            }) {[weak self] (error) in
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func nextButtonDidTouch(_ sender: Any) {
        verify()
    }
    
    func verify() {
        guard pinCodeInputView.text.count == ConfirmUserVC.numberOfDigits,
            let code = UInt64(pinCodeInputView.text) else {
                nextButton.isEnabled = false
                return
        }
        
        nextButton.isEnabled = true
        
        showIndetermineHudWithMessage("verifying...".localized().uppercaseFirst)
        
        RestAPIManager.instance.verify(code: code)
            .subscribe(onSuccess: { [weak self] (_) in
                self?.hideHud()
                self?.signUpNextStep()
            }) { (error) in
                self.deleteCode()
                guard let phone = Config.currentUser?.phoneNumber else {
                    self.hideHud()
                    self.showError(error)
                    return
                }
                self.handleSignUpError(error: error, with: phone)
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
        self.titleLabel?.font       =   UIFont.systemFont(ofSize: 15, weight: .semibold)

        // Localize label
        if let text = titleLabel?.text {
            setTitle(text.localized().uppercaseFirst, for: .normal)
            setTitleColor(.white, for: .normal)
        }
    }
}
