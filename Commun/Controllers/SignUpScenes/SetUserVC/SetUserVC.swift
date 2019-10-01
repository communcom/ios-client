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
            tuneCreateUserNameLabel()
        }
    }
    
    @IBOutlet weak var userNameTextField: FormTextField! {
        didSet {
            tuneUserNameTextField()
        }
    }
    @IBOutlet var traitLabels: [UILabel]! {
        didSet {
            tuneTraitLabels()
        }
    }
    
    @IBOutlet weak var nextButton: StepButton!
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil {
            viewModel = SetUserViewModel()
        }

        self.title = "sign up".localized().uppercaseFirst
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
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
                
                // Change text color
                for i in 0..<checkResult.count {
                    self.traitLabels[i].textColor = checkResult[i] ? .lightGray: .red
                }
            })
            .disposed(by: disposeBag)
    }
}
