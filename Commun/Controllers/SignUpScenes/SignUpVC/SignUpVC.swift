//
//  SignUpVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 10/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CyberSwift
import PhoneNumberKit
import CoreLocation
import ReCaptcha

class SignUpVC: UIViewController, SignUpRouter {
    // MARK: - Properties
    let viewModel   =   SignUpViewModel()
    let disposeBag  =   DisposeBag()
    var locationManager: CLLocationManager!
    var shouldDefineLocation = true
    
    private var recaptcha: ReCaptcha!
    private let locale = Locale(identifier: Locale.current.languageCode ?? "en")
    private var endpoint = ReCaptcha.Endpoint.default

    
    // MARK: - IBOutlets
    @IBOutlet weak var countryButton: UIButton!
    
    @IBOutlet weak var countryImageView: UIImageView! {
        didSet {
            self.countryImageView.layer.cornerRadius = 24.0 * Config.heightRatio / 2
            self.countryImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var placeholderSelectCountryLabel: UILabel! {
        didSet {
            self.placeholderSelectCountryLabel.tune(withText:       "select country placeholder".localized().uppercaseFirst,
                                                    hexColors:      darkGrayishBluePickers,
                                                    font:           UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                                    alignment:      .left,
                                                    isMultiLines:   false)
        }
    }

    @IBOutlet weak var countryLabel: UILabel! {
        didSet {
            self.countryLabel.tune(withText:       "",
                                   hexColors:      blackWhiteColorPickers,
                                   font:           UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                   alignment:      .left,
                                   isMultiLines:   false)
        }
    }

    @IBOutlet weak var countryView: UIView! {
        didSet {
            self.countryView.layer.cornerRadius = 8.0 * Config.heightRatio
            self.countryView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField! {
        didSet {
            self.phoneNumberTextField.tune(withPlaceholder:     "phone number placeholder".localized().uppercaseFirst,
                                           textColors:          blackWhiteColorPickers,
                                           font:                UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                           alignment:           .left)
            
            // Configure textView
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16 * Config.widthRatio, height: 20))
            phoneNumberTextField.leftView = paddingView
            phoneNumberTextField.leftViewMode = .always
            
            self.phoneNumberTextField.layer.cornerRadius = 8.0 * Config.heightRatio
            self.phoneNumberTextField.clipsToBounds = true
            self.phoneNumberTextField.keyboardType = .numberPad
        }
    }
    
    @IBOutlet weak var nextButton: StepButton!
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "sign up".localized().uppercaseFirst
        self.navigationController?.navigationBar.prefersLargeTitles = true

        self.setupBindings()
        self.setupActions()
        
        updateLocation()
        setupReCaptcha()
    }
    
    
    // MARK: - Custom Functions
    func setupBindings() {
        let country = viewModel.selectedCountry
            
        country
            .filter {$0 != nil}
            .subscribe(onNext: { (_) in
                self.shouldDefineLocation = false
            })
            .disposed(by: disposeBag)
        
        // Bind country name
        let countryName = country.map {$0?.localizedName}
        countryName.map {$0 ?? "select country".localized().uppercaseFirst}
            .bind(to: countryLabel.rx.text)
            .disposed(by: disposeBag)
        
        countryName.map {$0 != nil}
            .subscribe(onNext: {[weak self] flag in
                self?.placeholderSelectCountryLabel.isHidden = flag
                self?.countryLabel.isHidden = !flag
                self?.countryImageView.isHidden = !flag
            })
            .disposed(by: disposeBag)
        
        // Bind flag url
        let flagUrl = country.filter {$0 != nil}.map {$0!.flagURL}
        flagUrl
            .subscribe(onNext: { [weak self] url in
                self?.countryImageView.sd_setImage(with: url, completed: nil)
            })
            .disposed(by: disposeBag)
        
        // Bind textField
        country
            .filter {$0 != nil}
            .map {$0!}
            .distinctUntilChanged {$0.code == $1.code}
            .map {"+\($0.code)"}
            .bind(to: phoneNumberTextField.rx.text)
            .disposed(by: disposeBag)
        
        // Bind phone
        phoneNumberTextField.rx.text.orEmpty
            .map {text -> String in
                var newText = text
                if country.value != nil, !newText.contains("+\(country.value!.code)") {
                    if "+\(country.value!.code)".contains(text) {return "+\(country.value!.code)"}
                    newText = "+\(country.value!.code)\(newText)"
                }
                return newText
            }
            .subscribe(onNext: { (text) in
                self.phoneNumberTextField.text = text
                self.viewModel.phone.accept(text)
            })
            .disposed(by: disposeBag)
        
        // Bind button
        viewModel.phone
            .map {_ in self.viewModel.validatePhoneNumber()}
            .bind(to: self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    func setupActions() {
        self.countryButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                if let countryVC = controllerContainer.resolve(SelectCountryVC.self) {
                    countryVC.bindViewModel(SelectCountryViewModel(withModel: self!.viewModel))
                    let nav = UINavigationController(rootViewController: countryVC)
                    self?.present(nav, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupReCaptcha() {
        recaptcha = try! ReCaptcha(endpoint: endpoint, locale: locale)
        recaptcha.forceVisibleChallenge = true

        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = 777
        }
    }

    
    // MARK: - Gestures
    @IBAction func handlingTapGesture(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard self.viewModel.validatePhoneNumber() else {
            self.showAlert(title: "error".localized().uppercaseFirst, message: "wrong phone number".localized().uppercaseFirst)
            return
        }
        
        // reCaptcha
        recaptcha.validate(on:              view,
                           resetOnError:    false,
                           completion:      { [weak self] (result: ReCaptchaResult) in
                            guard let strongSelf = self else { return }
                            
                            guard let captchaCode = try? result.dematerialize() else {
                                print("XXX")
                                return
                            }
                            
                            print(captchaCode)
                            strongSelf.view.viewWithTag(777)?.removeFromSuperview()
                            
                            // API `registration.firstStep`
                            strongSelf.showIndetermineHudWithMessage("signing you up".localized().uppercaseFirst + "...")
                            
                            RestAPIManager.instance.rx.firstStep(phone: strongSelf.viewModel.phone.value, captchaCode: captchaCode)
                                .subscribe(onSuccess: { _ in
                                    strongSelf.hideHud()
                                    strongSelf.signUpNextStep()
                                }) { (error) in
                                    strongSelf.hideHud()
                                    strongSelf.handleSignUpError(error: error, with: strongSelf.viewModel.phone.value)
                            }
                            .disposed(by: strongSelf.disposeBag)
        })
    }
}
