//
//  SignUpVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 10/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class SignUpVC: UIViewController {

    let viewModel = SignUpViewModel()
    
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: FormTextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sign up"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        countryButton.layer.cornerRadius = 10
        phoneNumberTextField.layer.cornerRadius = 12
        nextButton.layer.cornerRadius = 8
        
        phoneNumberTextField.clipsToBounds = true
        
        setupBindings()
        setupActions()
    }
    
    func setupBindings() {
        viewModel.country.asObservable().bind(to: countryButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.phone.asObservable().bind(to: phoneNumberTextField.rx.text).disposed(by: disposeBag)
        viewModel.flagUrl.subscribe(onNext: { [weak self] url in
            self?.countryButton.sd_setImage(with: url, for: .normal, completed: nil)
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
            if let vc = controllerContainer.resolve(ConfirmUserVC.self) {
                let nav = UINavigationController(rootViewController: vc)
                self?.present(nav, animated: true, completion: nil)
            }
            
//            self?.viewModel.signUp().subscribe(onNext: { code in
//                self?.showAlert(title: "CODE", message: "\(code)")
//                print("code \(code)")
//            }).disposed(by: self!.disposeBag)
        }).disposed(by: disposeBag)
    }
}
