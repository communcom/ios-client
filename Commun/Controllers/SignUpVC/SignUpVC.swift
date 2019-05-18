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

class SignUpVC: UIViewController {
    // MARK: - Properties
    let viewModel   =   SignUpViewModel()
    let disposeBag  =   DisposeBag()

    var router: (NSObjectProtocol & SignUpRoutingLogic)?

    
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
            self.placeholderSelectCountryLabel.tune(withText:       "Select Country Placeholder".localized(),
                                                    hexColors:      darkGrayishBluePickers,
                                                    font:           UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                                    alignment:      .left,
                                                    isMultiLines:   false)
        }
    }

    @IBOutlet weak var countryLabel: UILabel! {
        didSet {
            self.countryLabel.tune(withText:       "",
                                   hexColors:      blackWhiteColorPickers,
                                   font:           UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
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
    
    @IBOutlet weak var phoneNumberTextField: FormTextField! {
        didSet {
            self.phoneNumberTextField.tune(withPlaceholder:     "Phone Number Placeholder".localized(),
                                           textColors:          blackWhiteColorPickers,
                                           font:                UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                           alignment:           .left)
            
            self.phoneNumberTextField.inset = 16.0 * Config.widthRatio
            self.phoneNumberTextField.layer.cornerRadius = 8.0 * Config.heightRatio
            self.phoneNumberTextField.clipsToBounds = true
            self.phoneNumberTextField.keyboardType = .numberPad
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
        
    
    // MARK: - Class Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    
    
    // MARK: - Setup
    private func setup() {
        let router                  =   SignUpRouter()
        router.viewController       =   self
        self.router                 =   router
    }
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sign up".localized()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.setupBindings()
        self.setupActions()
    }
    
    
    // MARK: - Custom Functions
    func setupBindings() {
        let country = viewModel.country.asObservable()
        country.bind(to: countryLabel.rx.text).disposed(by: disposeBag)
        
        country
            .map { country -> Bool in
                return country != "Select country"
            }
            .subscribe(onNext: { [weak self] flag in
                self?.placeholderSelectCountryLabel.isHidden = flag
                self?.countryLabel.isHidden = !flag
                self?.countryImageView.isHidden = !flag
            })
            .disposed(by: disposeBag)
        
        self.viewModel.phone.asObservable()
            .bind(to: phoneNumberTextField.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.flagUrl
            .subscribe(onNext: { [weak self] url in
                self?.countryImageView.sd_setImage(with: url, completed: nil)
            })
            .disposed(by: disposeBag)
        
        self.phoneNumberTextField.rx.text
            .map({ text -> String in
                return text ?? ""
            })
            .bind(to: viewModel.phone).disposed(by: disposeBag)
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
    
    
    // MARK: - Gestures
    @IBAction func handlingTapGesture(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard self.viewModel.checkLogin() else {
            self.showAlert(title: "Error".localized(), message: "Select county".localized())
            return
        }

        guard self.viewModel.validatePhoneNumber() else {
            self.showAlert(title: "Error".localized(), message: "Wrong phone number".localized())
            return
        }
        
        RestAPIManager.instance.firstStep(phone:                self.viewModel.phone.value,
                                          responseHandling:     { result in
                                            self.router?.routeToSignUpNextScene()
        },
                                          errorHandling:        { responseAPIError in
                                            guard responseAPIError.currentState == nil else {
                                                self.router?.routeToSignUpNextScene()
                                                return
                                            }
                                            
                                            self.showAlert(title: "Error", message: responseAPIError.message)
        })
    }
}
