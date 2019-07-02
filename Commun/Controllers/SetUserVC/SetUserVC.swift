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
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil {
            viewModel = SetUserViewModel()
        }

        self.title = "Sign up".localized()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.bind()
    }
    
    func setButtonState(enabled: Bool = false) {
        self.nextButton.isEnabled = enabled
        self.nextButton.backgroundColor = enabled ? #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1) :#colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 0.3834813784)
    }

    // MARK: - Custom Functions
    func bind() {
        let userName = userNameTextField.rx.text.orEmpty
        
        userName
            .subscribe(onNext: {text in
                self.setButtonState(enabled: self.viewModel.checkUserName(text))
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withLatestFrom(userName)
            .filter {self.viewModel.checkUserName($0)}
            .flatMapLatest {self.viewModel.setUser()}
    }
    
    func setupActions() {
        nextButton.rx.tap
            .subscribe(onNext: { _ in
                self.viewModel!.setUser()
                    .subscribe(onNext: { flag in
                        self.signUpNextStep()
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Gestures
    @IBAction func handlerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
