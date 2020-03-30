//
//  SignUpWithPhoneVC.swift
//  Commun
//
//  Created by Chung Tran on 3/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import PhoneNumberKit
import CoreLocation
import ReCaptcha

class SignUpWithPhoneVC: BaseSignUpMethodVC {
    // MARK: - Properties
    let viewModel = SignUpWithPhoneViewModel()
    var shouldDefineLocation = true
    let locationManager = CLLocationManager()
    lazy var recaptcha: ReCaptcha = {
        let recaptcha = try! ReCaptcha(endpoint: ReCaptcha.Endpoint.default, locale: Locale(identifier: Locale.current.languageCode ?? "en"))

        #if DEBUG
        recaptcha.forceVisibleChallenge = false
        #endif

        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = reCaptchaTag
            self?.hideHud()
        }
        return recaptcha
    }()
    
    // MARK: - Subviews
    lazy var selectCountryView: UIView = {
        let view = UIView(width: 290, height: 56, backgroundColor: .f3f5fa, cornerRadius: 12)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseCountry)))
        return view
    }()
    
    lazy var selectCountryPlaceholderLabel = UILabel.with(text: "select country placeholder".localized().uppercaseFirst, textSize: 17, textColor: UIColor(hexString: "#9B9FA2")!)
    
    lazy var flagView = UILabel.with(textSize: 28)
    lazy var countryNameLabel = UILabel.with(textSize: 17)
    
    lazy var phoneTextField: PhoneNumberTextField = {
        let tf = PhoneNumberTextField(width: 290, height: 56, backgroundColor: .f3f5fa, cornerRadius: 12)
        let paddingView = UIView(width: 16, height: 20)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.placeholder = "phone number placeholder".localized().uppercaseFirst
        tf.setPlaceHolderTextColor(UIColor(hexString: "#9B9FA2")!)
        return tf
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.registrationOpenScreen(2)
        
        // get location
        updateLocation()
    }
    
    override func setUpInputViews() {
        // select country view
        scrollView.contentView.addSubview(selectCountryView)
        selectCountryView.autoPinEdge(toSuperviewEdge: .top, withInset: UIScreen.main.isSmall ? 16 : 47)
        selectCountryView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // phone text field
        scrollView.contentView.addSubview(phoneTextField)
        phoneTextField.autoPinEdge(.top, to: .bottom, of: selectCountryView, withOffset: 16)
        phoneTextField.autoAlignAxis(toSuperviewAxis: .vertical)
    }
    
    override func pinBottomOfInputViews() {
        termOfUseLabel.autoPinEdge(.top, to: .bottom, of: phoneTextField, withOffset: 30)
    }
    
    override func bind() {
        super.bind()
        
        bindCountry()
        
        bindPhoneNumber()
    }
    
    override func nextButtonDidTouch() {
        handleNextAction()
    }
}
