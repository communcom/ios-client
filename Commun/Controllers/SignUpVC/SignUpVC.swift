//
//  SignUpVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 10/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpVC: UIViewController {

    let viewModel = SignUpViewModel()
    
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var selectCountryLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var phoneNumberTextField: FormTextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sign up"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
//        countryButton.layer.cornerRadius = 10
        phoneNumberTextField.layer.cornerRadius = 12
        nextButton.layer.cornerRadius = 8
        
        phoneNumberTextField.clipsToBounds = true
        
        countryImageView.layer.cornerRadius = 12
        countryImageView.clipsToBounds = true
        
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
        
        nextButton.rx.tap.subscribe(onNext: { [weak self] _ in
            if self?.viewModel.validatePhoneNumber() ?? false {
                self?.viewModel.signUp().subscribe(onNext: { code in
                    if let vc = controllerContainer.resolve(ConfirmUserVC.self) {
                        vc.viewModel = ConfirmUserViewModel(code: "\(code)", phone: self?.viewModel.phone.value ?? "")
                        let nav = UINavigationController(rootViewController: vc)
                        self?.present(nav, animated: true, completion: nil)
                    }

                }).disposed(by: self!.disposeBag)
            } else {
                self?.showAlert(title: "Error", message: "Worng phone number")
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification, object: nil).subscribe(onNext: { [weak self] notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self?.nextButtonBottomConstraint.constant = keyboardHeight
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification, object: nil).subscribe(onNext: { [weak self] notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self?.nextButtonBottomConstraint.constant = keyboardHeight
            }
        }).disposed(by: disposeBag)
        
    }
}
