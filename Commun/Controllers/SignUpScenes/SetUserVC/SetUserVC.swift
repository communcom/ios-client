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

class SetUserVC: UIViewController, SignUpRouter {
    // MARK: - Properties
    var viewModel: SetUserViewModel!
    let disposeBag = DisposeBag()

    
    // MARK: - IBOutlets
    @IBOutlet weak var creatUsernameLabel: UILabel! {
        didSet {
            self.creatUsernameLabel.tune(withText:      "Create your username".localized(),
                                         hexColors:     blackWhiteColorPickers,
                                         font:          UIFont(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                         alignment:     .left,
                                         isMultiLines:  false)
        }
    }
    
    @IBOutlet weak var userNameTextField: FormTextField! {
        didSet {
            self.userNameTextField.tune(withPlaceholder:    "Username Placeholder".localized(),
                                        textColors:         blackWhiteColorPickers,
                                        font:               UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                        alignment:          .left)
            
            self.userNameTextField.inset = 16.0 * Config.widthRatio
            self.userNameTextField.layer.cornerRadius = 8.0 * Config.heightRatio
            self.userNameTextField.clipsToBounds = true
            self.userNameTextField.keyboardType = .alphabet
        }
    }
    
    @IBOutlet weak var nextButton: StepButton!
    
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
        
        if viewModel == nil {
            viewModel = SetUserViewModel()
        }

        self.title = "Sign up".localized()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        setBackButtonToSignUpVC()
        
        self.bind()
    }

    // MARK: - Custom Functions
    func bind() {
        userNameTextField.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.nextButton.isEnabled = self.viewModel.checkUserName(text)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func buttonNextDidTouch(_ sender: Any) {
        guard let phone = KeychainManager.currentUser()?.phoneNumber else {
            resetSignUpProcess()
            return
        }
        
        guard let userName = userNameTextField.text,
            viewModel.checkUserName(userName) else {
                return
        }
        
        self.view.endEditing(true)
        
        showIndetermineHudWithMessage("Setting username".localized() + "...")
        viewModel.setUser(userName: userName, phone: phone)
            .flatMapCompletable({ (id) -> Completable in
                self.showIndetermineHudWithMessage("Saving to blockchain".localized() + "...")
                return RestAPIManager.instance.rx.toBlockChain()
            })
            .subscribe(onCompleted: {
                AppDelegate.reloadSubject.onNext(true)
            }, onError: {error in
                self.hideHud()
                self.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Gestures
    @IBAction func handlerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
