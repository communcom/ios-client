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

class SetUserVC: UIViewController, SignUpRouter {
    // MARK: - Properties
    var viewModel: SetUserViewModel!
    let disposeBag = DisposeBag()

    var userNameRulesView: UserNameRulesView = UserNameRulesView(frame: CGRect(x: CGFloat.adaptive(width: 10.0), y: 0.0, width: CGFloat.adaptive(width: 355.0), height: CGFloat.adaptive(height: 386.0)))
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var nextButton: StepButton!

    @IBOutlet weak var creatUsernameLabel: UILabel! {
        didSet {
            tuneCreateUserNameLabel()
        }
    }
    
    @IBOutlet weak var userNameTextField: FormTextField! {
        didSet {
            tuneUserNameTextField()
        }
    }
        
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil {
            viewModel = SetUserViewModel()
        }

        self.title = "sign up".localized().uppercaseFirst
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.setNavBarBackButton()

        self.view.addSubview(self.userNameRulesView)
        self.userNameRulesView.display(false)
        
        self.userNameRulesView.handlerHide = {
            self.showBlackoutView(false)
        }

        setBackButtonToSignUpVC()
        
        self.bind()
    }

    
    // MARK: - Custom Functions
    func bind() {
        userNameTextField.rx.text.orEmpty
            .subscribe(onNext: {text in
                // result
                let checkResult = self.viewModel.checkUserName(text)
                
                // Enable, disable nextButton
                self.nextButton.isEnabled =
                    checkResult.reduce(true, { (result, element) -> Bool in
                        return result && element
                    })
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Actions
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        self.showBlackoutView(true)
        self.view.bringSubviewToFront(self.userNameRulesView)
        self.userNameRulesView.display(true)
    }
}
