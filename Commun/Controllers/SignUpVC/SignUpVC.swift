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
    @IBOutlet weak var selectCountryLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var countryImageView: UIImageView! {
        didSet {
            self.countryImageView.layer.cornerRadius    =   12.0
            self.countryImageView.clipsToBounds         =   true
        }
    }
   
    @IBOutlet weak var phoneNumberTextField: FormTextField! {
        didSet {
            self.phoneNumberTextField.layer.cornerRadius    =   12.0
            self.phoneNumberTextField.clipsToBounds         =   true
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            self.nextButton.layer.cornerRadius  =   8.0
            self.nextButton.clipsToBounds       =   true
        }
    }
    
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    
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

        self.title = "Sign up"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        setupBindings()
        setupActions()
    }
    
    func setupBindings() {
        let country = viewModel.country.asObservable()
        country.bind(to: countryLabel.rx.text).disposed(by: disposeBag)
        
        country.map { country -> Bool in
            return country != "Select country"
        }.subscribe(onNext: { [weak self] flag in
            self?.selectCountryLabel.isHidden = flag
            self?.countryLabel.isHidden = !flag
            self?.countryImageView.isHidden = !flag
        }).disposed(by: disposeBag)
        
        viewModel.phone.asObservable().bind(to: phoneNumberTextField.rx.text).disposed(by: disposeBag)
        viewModel.flagUrl.subscribe(onNext: { [weak self] url in
            self?.countryImageView.sd_setImage(with: url, completed: nil)
        }).disposed(by: disposeBag)
        
        self.phoneNumberTextField.rx.text.map({ text -> String in
            return text ?? ""
        }).bind(to: viewModel.phone).disposed(by: disposeBag)
    }

    func setupActions() {
        countryButton.rx.tap.subscribe(onNext: { [weak self] _ in
            if let countryVC = controllerContainer.resolve(SelectCountryVC.self) {
                countryVC.bindViewModel(SelectCountryViewModel(withModel: self!.viewModel))
                let nav = UINavigationController(rootViewController: countryVC)
                self?.present(nav, animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)
        
//        nextButton.rx.tap.subscribe(onNext: { [weak self] _ in
//            if self?.viewModel.validatePhoneNumber() ?? false {
//                self?.viewModel.signUp().subscribe(onNext: { code in
//                    self?.router?.routeToSignUpNextScene()
//                }).disposed(by: self!.disposeBag)
//            } else {
//                self?.showAlert(title: "Error", message: "Wrong phone number")
//            }
//        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification, object: nil).subscribe(onNext: { [weak self] notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self?.nextButtonBottomConstraint.constant = keyboardHeight
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification, object: nil).subscribe(onNext: { [weak self] notification in
            guard let strongSelf = self else { return }
//            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//                let keyboardRectangle = keyboardFrame.cgRectValue
//                let keyboardHeight = keyboardRectangle.height
                strongSelf.nextButtonBottomConstraint.constant = 40.0
//            }
        }).disposed(by: disposeBag)
    }
    
    
    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard self.viewModel.validatePhoneNumber() else {
            self.showAlert(title: "Error", message: "Wrong phone number")
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
    
    
    // MARK: - Gestures
    
    @IBAction func handlingTapGesture(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
