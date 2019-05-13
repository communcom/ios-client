//
//  SetUserVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift

class SetUserVC: UIViewController {
    // MARK: - Properties
    var viewModel: SetUserViewModel?
    let disposeBag = DisposeBag()
    
    var router: (NSObjectProtocol & SignUpRoutingLogic)?

    
    // MARK: - IBOutlets
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    
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

        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = "Sign up"
        
        setBindings()
//        makeActions()
    }

    func setBindings() {
        if let viewModel = viewModel {
            userNameTextField.rx.text.map { string -> String in
                return string ?? ""
            }.bind(to: viewModel.userName).disposed(by: disposeBag)
        }
    }
    
//    func makeActions() {
//        nextButton.rx.tap.subscribe(onNext: { _ in
//            self.viewModel!.setUser().subscribe(onNext: { flag in
//                self.router?.routeToSignUpNextScene()
//            }).disposed(by: self.disposeBag)
//        }).disposed(by: disposeBag)
//    }
    
    
    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let phone = UserDefaults.standard.string(forKey: Config.registrationUserPhoneKey) else { return }

        guard let userName = self.userNameTextField.text else {
            self.showAlert(title: "Error", message: "Enter user name")
            return
        }
        
        RestAPIManager.instance.setUser(nickName:           userName,
                                        phone:              phone,
                                        responseHandling:   { [weak self] result in
                                            guard let strongSelf = self else { return }
                                            strongSelf.router?.routeToSignUpNextScene()
        },
                                        errorHandling:      { [weak self] errorAPI in
                                            guard let strongSelf = self else { return }
                                            strongSelf.showAlert(title: "Error", message: errorAPI.caseInfo.message)
        })
    }
}
