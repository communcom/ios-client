//
//  MyProfileVerifyContactVC.swift
//  Commun
//
//  Created by Chung Tran on 7/27/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import PinCodeInputView

class MyProfileVerifyContactVC: BaseVerticalStackVC {
    // MARK: - Constants
    let contactType: ResponseAPIContentGetProfilePersonalMessengers.MessengerType
    let numberOfDigits = 4
    
    // MARK: - Properties
    var resendTimer: Timer?
    var resendSeconds = 45
    private var counter = 0
    
    // MARK: - Subviews
    lazy var pinCodeInputView = PinCodeInputView<ItemView>(
        digit: numberOfDigits,
        itemSpacing: 12,
        itemFactory: {
            let itemView = ItemView()
            let autoTestMarker = String(format: "ConfirmUserPinCodeInputView-%i", self.counter)
            
            // For autotest
            itemView.accessibilityLabel = autoTestMarker
            itemView.accessibilityIdentifier = autoTestMarker
            self.counter += 1
            
            return itemView
    })
    
    lazy var resendButton = UIButton(labelFont: .systemFont(ofSize: 15, weight: .semibold))
    
    // MARK: - Initializers
    init(contactType: ResponseAPIContentGetProfilePersonalMessengers.MessengerType) {
        self.contactType = contactType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pinCodeInputView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deleteCode()
        pinCodeInputView.resignFirstResponder()
    }
    
    override func setUp() {
        super.setUp()
        title = contactType.rawValue + " " + "confirmation".localized().uppercaseFirst
        
        // pinCodeInputView
        pinCodeInputView.set { _ in
            self.verify()
        }
        
        pinCodeInputView.set(
            appearance: ItemAppearance(
                itemSize: CGSize(width: 48, height: 56),
                font: .systemFont(ofSize: 26),
                textColor: .black,
                backgroundColor: #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1),
                cursorColor: UIColor(red: 69 / 255, green: 108 / 255, blue: 1, alpha: 1),
                cornerRadius: 8)
        )
        pinCodeInputView.autoSetDimensions(to: CGSize(width: 228.0, height: 56.0))
        
        // Run timer
        resendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    override func setUpArrangedSubviews() {
        let logo = UIImageView.circle(size: 64, imageName: contactType.rawValue.lowercased() + "-icon")
        let subtitle = UILabel.with(text: "enter 4 digit code we sent to your".localized().uppercaseFirst + " " + contactType.rawValue, textSize: 15, weight: .semibold, textColor: .appGrayColor, numberOfLines: 0, textAlignment: .center)
        
        stackView.addArrangedSubviews([
            logo,
            subtitle,
            pinCodeInputView,
            resendButton
        ])
    }
    
    override func viewDidSetUpStackView() {
        super.viewDidSetUpStackView()
        stackView.alignment = .center
        stackView.spacing = 20
    }
    
    // MARK: - Timer handler
    @objc func onTimerFires() {
        guard self.resendSeconds > 1 else {
            resendTimer?.invalidate()
            resendTimer = nil
            setResendButtonEnabled()
            return
        }
        
        resendSeconds -= 1
        setResendButtonEnabled(false)
    }
    
    private func setResendButtonEnabled(_ enabled: Bool = true) {
        if enabled {
            resendButton.isUserInteractionEnabled = true
            resendButton.setTitleColor(.appMainColor, for: .normal)
            resendButton.setTitle("resend verification code".localized().uppercaseFirst, for: .normal)
        } else {
            resendButton.isUserInteractionEnabled = false
            resendButton.setTitleColor(.appGrayColor, for: .normal)
            
            var time = ""
            time = " 0:\(String(describing: resendSeconds).addFirstZero())"
            resendButton.setTitle("code expires in".localized().uppercaseFirst + time, for: .normal)
        }
    }
    
    // MARK: - Actions
    private func verify() {
        
    }
    
    func deleteCode() {
        for _ in 0..<numberOfDigits {
            pinCodeInputView.deleteBackward()
        }
    }
}
