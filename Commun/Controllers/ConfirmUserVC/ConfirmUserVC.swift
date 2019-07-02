//
//  ConfirmUserVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift
import PinCodeInputView

class ConfirmUserVC: UIViewController, SignUpRouter {
    // MARK: - Properties
    var viewModel: ConfirmUserViewModel?
    let disposeBag = DisposeBag()
    
    var resendTimer: Timer?
    var resendSeconds: Int = 0
    
    let pinCodeInputView: PinCodeInputView<ItemView> = .init(
        digit: 4,
        itemSpacing: 12,
        itemFactory: {
            return ItemView()
    })

    
    // MARK: - IBOutlets
    @IBOutlet weak var pinCodeView: UIView!
    
    @IBOutlet weak var testSmsCodeLabel: UILabel! {
        didSet {
            guard isDebugMode else {
                self.testSmsCodeLabel.text = nil
                self.testSmsCodeLabel.isHidden = true
                return
            }
            
            if  let phone   =   UserDefaults.standard.string(forKey: Config.registrationUserPhoneKey),
                let currentUser    =   Config.currentUser,
                let smsCode =   currentUser.smsCode {
                self.testSmsCodeLabel.text = String(format: "sms code is: `%i`", smsCode)
                self.testSmsCodeLabel.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var smsCodeLabel: UILabel! {
        didSet {
            self.smsCodeLabel.tune(withText:      "Enter SMS-code".localized(),
                                   hexColors:     blackWhiteColorPickers,
                                   font:          UIFont(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                   alignment:     .center,
                                   isMultiLines:  false)
        }
    }
   
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            self.nextButton.tune(withTitle:     "Next".localized(),
                                 hexColors:     [whiteColorPickers, lightGrayWhiteColorPickers, lightGrayWhiteColorPickers, lightGrayWhiteColorPickers],
                                 font:          UIFont(name: "SFProText-Semibold", size: 17.0 * Config.heightRatio),
                                 alignment:     .center)
            
            self.nextButton.layer.cornerRadius = 8.0 * Config.heightRatio
            self.nextButton.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var resendButton: UIButton! {
        didSet {
            self.resendButton.isEnabled = true
            
            self.resendButton.tune(withTitle:     "Resend verification code".localized(),
                                   hexColors:     [softBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers],
                                   font:          UIFont(name: "SFProText-Semibold", size: 15.0 * Config.heightRatio),
                                   alignment:     .center)
        }
    }

    @IBOutlet weak var resendTimerLabel: UILabel! {
        didSet {
            self.resendTimerLabel.tune(withText:      "",
                                       hexColors:     verySoftBlueColorPickers,
                                       font:          UIFont(name: "SFProText-Semibold", size: 15.0 * Config.heightRatio),
                                       alignment:     .center,
                                       isMultiLines:  false)
            
            self.checkResendSmsCodeTime()
        }
    }
    
    @IBOutlet var heightsCollection: [NSLayoutConstraint]! {
        didSet {
            self.heightsCollection.forEach({ $0.constant *= Config.heightRatio })
        }
    }

    @IBOutlet var widthsCollection: [NSLayoutConstraint]! {
        didSet {
            self.widthsCollection.forEach({ $0.constant *= Config.widthRatio })
        }
    }
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Verification".localized()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Close bar button
        let closeButton = UIBarButtonItem(title: "Close".localized(), style: .plain, target: nil, action: nil)

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItem = closeButton

        self.pinCodeInputView.set(changeTextHandler: { text in
            print(text)
        })
        
        self.pinCodeInputView.set(appearance: .init(itemSize:         CGSize(width: 48.0 * Config.widthRatio, height: 56.0 * Config.heightRatio),
                                                    font:             .init(descriptor: UIFontDescriptor(name:  "SFProText-Regular",
                                                                                                         size:  26.0 * Config.heightRatio),
                                                                            size:   26.0 * Config.heightRatio),
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
        guard   let json    =   KeychainManager.currentUser(),
                let step    =   json.registrationStep, step == "verify",
                let date    =   json.smsNextRetry else {
                self.resendButton.isEnabled = true
                self.resendTimerLabel.isHidden = true
                return
        }
        
        self.resendButton.isEnabled = false
        self.resendTimerLabel.isHidden = false
        
        let dateNextSmsRetry    =   date.convert(toDateFormat: .nextSmsDateType)
        self.resendSeconds      =   Date().seconds(date: dateNextSmsRetry) - 2
        let deadlineTime        =   DispatchTime.now() + .seconds(resendSeconds) + 2
        
        // Run timer
        self.resendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.resendButton.isEnabled = true
            self.resendTimerLabel.isHidden = true
        }
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
            return
        }
        
        self.resendSeconds -= 1
        self.resendTimerLabel.text = "0:\(String(describing: self.resendSeconds).addFirstZero())"
    }

    @IBAction func resendButtonTapped(_ sender: UIButton) {
        RestAPIManager.instance.resendSmsCode(phone:                UserDefaults.standard.string(forKey: Config.registrationUserPhoneKey)!,
                                              responseHandling:     { [weak self] smsCode in
                                                guard let strongSelf = self else { return }
                                                
                                                strongSelf.showAlert(title:       "Info".localized(),
                                                                     message:     "Successfully resend code".localized(),
                                                                     completion:  { success in
                                                                        strongSelf.checkResendSmsCodeTime()
                                                })
        },
                                              errorHandling:        { [weak self] errorAPI in
                                                guard let strongSelf = self else { return }
                                                strongSelf.showAlert(title: "Error".localized(), message: "Failed: \(errorAPI.caseInfo.message)")
        })
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // Verify current step of registration
        guard   let user = KeychainManager.currentUser(),
                let step    =   user.registrationStep,
                step == "verify"
        else {
            self.signUpNextStep()
            return
        }
        
        // Get sms code
        guard let smsCode = user.smsCode else { return }

        if let viewModel = self.viewModel {
            viewModel.checkPin(self.pinCodeInputView.text)
                .subscribe(onNext: { success in
                    if success {
                        RestAPIManager.instance.verify(phone:               UserDefaults.standard.string(forKey: Config.registrationUserPhoneKey) ?? "",
                                                       code:                smsCode,
                                                       responseHandling:    { [weak self] result in
                                                        guard let strongSelf = self else { return }
                                                        strongSelf.signUpNextStep()
                            },
                                                       errorHandling:       { [weak self] responseAPIError in
                                                        guard let strongSelf = self else { return }
                                                        guard responseAPIError.currentState == nil else {
                                                            strongSelf.signUpNextStep()
                                                            return
                                                        }
                                                        
                                                        strongSelf.showAlert(title: "Error", message: responseAPIError.message)
                        })
                    } else {
                        self.showAlert(title: "Error".localized(), message: "Enter correct sms code".localized())
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
}
