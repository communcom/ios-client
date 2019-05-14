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
    @IBOutlet weak var creatUsernameLabel: UILabel! {
        didSet {
            self.creatUsernameLabel.tune(withText:      "Create your username".localized(),
                                         hexColors:     blackWhiteColorPickers,
                                         font:          UIFont(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                         alignment:     .left,
                                         isMultiLines:  false)
        }
    }
    
    @IBOutlet weak var userNameTextField: UITextField! {
        didSet {
            self.userNameTextField.tune(withPlaceholder:        "Username Placeholder".localized(),
                                        textColors:             blackWhiteColorPickers,
                                        font:                   UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                        alignment:              .left)
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

        guard let userNickName = self.viewModel?.userName.value, (self.viewModel?.checkUserName())! else {
            self.showAlert(title: "Error".localized(), message: "Enter correct user name".localized())
            return
        }
        
        RestAPIManager.instance.setUser(nickName:           userNickName,
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
