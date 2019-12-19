//
//  SignUpVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 10/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CyberSwift
import PhoneNumberKit
import CoreLocation
import ReCaptcha
import SafariServices

class SignUpVC: UIViewController, SignUpRouter {
    // MARK: - Properties
    let viewModel = SignUpViewModel()
    let disposeBag = DisposeBag()
    var locationManager: CLLocationManager!
    var shouldDefineLocation = true
    
    private var recaptcha: ReCaptcha!
    private let locale = Locale(identifier: Locale.current.languageCode ?? "en")
    private var endpoint = ReCaptcha.Endpoint.default
    
    // MARK: - IBOutlets
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var flagLabel: UILabel!
    
    @IBOutlet weak var placeholderSelectCountryLabel: UILabel! {
        didSet {
            self.placeholderSelectCountryLabel.tune(withText: "select country placeholder".localized().uppercaseFirst,
                                                    hexColors: darkGrayishBluePickers,
                                                    font: UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                                    alignment: .left,
                                                    isMultiLines: false)
        }
    }

    @IBOutlet weak var countryLabel: UILabel! {
        didSet {
            self.countryLabel.tune(withText: "",
                                   hexColors: blackWhiteColorPickers,
                                   font: UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                   alignment: .left,
                                   isMultiLines: false)
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
            self.phoneNumberTextField.tune(withPlaceholder: "phone number placeholder".localized().uppercaseFirst,
                                           textColors: blackWhiteColorPickers,
                                           font: UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                           alignment: .left)
            
            // Configure textView
            let paddingView: UIView = UIView(width: 16 * Config.widthRatio, height: 20)
            phoneNumberTextField.leftView = paddingView
            phoneNumberTextField.leftViewMode = .always

            self.phoneNumberTextField.layer.cornerRadius = 8.0 * Config.heightRatio
            self.phoneNumberTextField.clipsToBounds = true
            self.phoneNumberTextField.keyboardType = .numberPad
        }
    }
    
    @IBOutlet weak var nextButton: StepButton!
    
    lazy var termOfUseLabel = UILabel.with(textSize: 10, numberOfLines: 0, textAlignment: .center)
    lazy var signInLabel = UILabel.with(textSize: 15, textAlignment: .center)
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "sign up".localized().uppercaseFirst
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // term of use
        view.addSubview(termOfUseLabel)
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        termOfUseLabel.autoPinEdge(.bottom, to: .top, of: nextButton, withOffset: -16)
        termOfUseLabel.isUserInteractionEnabled = true
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapTermOfUseLabel(gesture:)))
        termOfUseLabel.addGestureRecognizer(tap1)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = .center
        let aStr = NSAttributedString(
            string: "By clicking the “Sign up” button, you agree to the\nTerms of use, Privacy Policy and Blockchain Disclaimer".localized().uppercaseFirst,
            attributes: [
                .foregroundColor: UIColor.a5a7bd,
                .font: UIFont.systemFont(ofSize: 10),
                .paragraphStyle: style
            ]
        )
            .applying(attributes: [.foregroundColor: UIColor.appMainColor], toOccurrencesOf: "terms of use, Privacy Policy".localized().uppercaseFirst)
            .applying(attributes: [.foregroundColor: UIColor.appMainColor], toOccurrencesOf: "blockchain Disclaimer".localized().uppercaseFirst)
        termOfUseLabel.attributedString = aStr
        
        // sign in
        view.addSubview(signInLabel)
        signInLabel.autoPinEdge(.top, to: .bottom, of: nextButton, withOffset: 16)
        signInLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        signInLabel.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tapSignInLabel(gesture:)))
        signInLabel.addGestureRecognizer(tap2)
        
        let aStr2 = NSAttributedString(
            string: "do you have account? Sign in".localized().uppercaseFirst,
            attributes: [.foregroundColor: UIColor.a5a7bd, .font: UIFont.systemFont(ofSize: 15)]
        )
            .applying(attributes: [.foregroundColor: UIColor.appMainColor], toOccurrencesOf: "sign in".localized().uppercaseFirst)
        signInLabel.attributedString = aStr2

        self.setNavBarBackButton()
        self.setupBindings()
        self.setupActions()

        updateLocation()
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
        let countryName = country.map {$0?.name}
        countryName.map {$0 ?? "select country".localized().uppercaseFirst}
            .bind(to: countryLabel.rx.text)
            .disposed(by: disposeBag)
        
        countryName.map {$0 != nil}
            .subscribe(onNext: {[weak self] flag in
                self?.placeholderSelectCountryLabel.isHidden = flag
                self?.countryLabel.isHidden = !flag
                self?.flagLabel.isHidden = !flag
            })
            .disposed(by: disposeBag)

        // Bind flag
        country.map {$0?.emoji}
            .bind(to: flagLabel.rx.text)
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
                if let code = country.value?.code {
                    var newText = text
                    let cleanPhone = newText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                    if !("+\(cleanPhone)").contains("+\(code)") {

                        if "+\(country.value!.code)".contains(text) {
                            return "+\(code)"
                        }

                        newText = "+\(code)\(newText)"
                    }
                    return newText
                }
                return text
            }
            .subscribe(onNext: { (text) in
                if self.phoneNumberTextField.isFirstResponder && text.isEmpty {
                    self.showContriesList()
                } else {
                    self.phoneNumberTextField.text = text
                    self.viewModel.phone.accept(text)
                }
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
                self?.showContriesList()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupReCaptcha() {
        recaptcha = try! ReCaptcha(endpoint: endpoint, locale: locale)

        #if DEBUG
        recaptcha.forceVisibleChallenge = false
        #endif

        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = reCaptchaTag
            self?.hideHud()
        }
    }

    private func showContriesList() {
         if let countryVC = controllerContainer.resolve(SelectCountryVC.self) {
             self.view.endEditing(true)
             countryVC.bindViewModel(SelectCountryViewModel(withModel: self.viewModel))
             let nav = UINavigationController(rootViewController: countryVC)
             self.present(nav, animated: true, completion: nil)
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
        AnalyticsManger.shared.PhoneNumberEntered()

        self.showIndetermineHudWithMessage("signing you up".localized().uppercaseFirst + "...")
        
        self.view.endEditing(true)
        self.setupReCaptcha()
        
        // reCaptcha
        self.recaptcha.validate(on: view,
                                resetOnError: false,
                                completion: { [weak self] (result: ReCaptchaResult) in
                                    guard let strongSelf = self else { return }
                                    
                                    guard let captchaCode = try? result.dematerialize() else {
                                        print("XXX")
                                        return
                                    }
                                    
                                    print(captchaCode)                                    
                                strongSelf.view.viewWithTag(reCaptchaTag)?.removeFromSuperview()
                                    
                                    RestAPIManager.instance.firstStep(phone: strongSelf.viewModel.phone.value, captchaCode: captchaCode)
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
    
    @objc func tapSignInLabel(gesture: UITapGestureRecognizer) {
        guard let text = signInLabel.text else {return}
        AnalyticsManger.shared.goToSingIn()
        let signInRange = (text as NSString).range(of: "sign in".localized().uppercaseFirst)
        
        let nc = navigationController
        if gesture.didTapAttributedTextInLabel(label: signInLabel, inRange: signInRange) {
            navigationController?.popViewController(animated: true, {
                let signInVC = SignInVC()
                nc?.pushViewController(signInVC)
            })
        }
    }
    
    @objc func tapTermOfUseLabel(gesture: UITapGestureRecognizer) {
        guard let text = termOfUseLabel.text else {return}
        
        let termsOfUseRange = (text as NSString).range(of: "terms of use, Privacy Policy".localized().uppercaseFirst)
        let blockChainDisclaimerRange = (text as NSString).range(of: "blockchain Disclaimer".localized().uppercaseFirst)
        
        if gesture.didTapAttributedTextInLabel(label: termOfUseLabel, inRange: termsOfUseRange) {
            showURL(string: "https://commun.com/doc/privacy")
        } else if gesture.didTapAttributedTextInLabel(label: termOfUseLabel, inRange: blockChainDisclaimerRange) {
            showURL(string: "https://commun.com/doc/disclaimer")
        }
    }
    
    func showURL(string: String) {
        guard let url = URL(string: string) else {return}
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
}
