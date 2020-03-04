//
//  WelcomeVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import SwiftTheme

class WelcomeVC: UIViewController {
    // MARK: - Properties
    var welcomePageVC: WelcomePageVC!
    lazy var pageControl = CMPageControll(numberOfPages: 3)
    
    // MARK: - IBOutlets
    @IBOutlet weak var nextButton: StepButton!
    @IBOutlet weak var coinImageView: UIImageView! {
        didSet {
            self.coinImageView.isHidden = true
        }
    }

    @IBOutlet weak var buttonsStackView: UIStackView!
    
    @IBOutlet weak var bottomSignInButton: StepButton! {
        didSet {
            self.bottomSignInButton.commonInit(backgroundColor: UIColor(hexString: "#F3F5FA"),
                                               font: .boldSystemFont(ofSize: 15.0),
                                               cornerRadius: self.bottomSignInButton.height / 2)
            
            self.bottomSignInButton.setTitleColor(UIColor(hexString: "#6A80F5"), for: .normal)
            self.bottomSignInButton.isHidden = true
        }
    }

    @IBOutlet weak var topSignInButton: BlankButton! {
        didSet {
            self.topSignInButton.commonInit(hexColors: [blackWhiteColorPickers, grayishBluePickers, grayishBluePickers, grayishBluePickers],
                                            font: UIFont.systemFont(ofSize: 15.0, weight: .medium),
                                            alignment: .right)
        }
    }
    
    @IBOutlet var actionButtonsCollection: [StepButton]! {
        didSet {
            self.actionButtonsCollection.forEach {
                $0.commonInit(backgroundColor: .appMainColor,
                              font: .boldSystemFont(ofSize: 15.0),
                              cornerRadius: $0.height / 2)
                $0.heightConstraint?.constant = 50
            }
        }
    }
    
    @IBOutlet weak var signUpButton: StepButton! {
        didSet {
            self.signUpButton.isHidden = true
        }
    }
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if signUp is processing
        if KeychainManager.currentUser()?.registrationStep != nil
        {
            navigateToSignUp()
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        view.addSubview(pageControl)
        pageControl.autoAlignAxis(.horizontal, toSameAxisOf: topSignInButton)
        pageControl.autoAlignAxis(toSuperviewAxis: .vertical)
        pageControl.selectedIndex = 0

        bottomSignInButton.heightConstraint?.constant = 50
        signUpButton.heightConstraint?.constant = 50
        nextButton.heightConstraint?.constant = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WelcomePageVC, segue.identifier == "WelcomePageSegue" {
            self.welcomePageVC = destination
        }
    }
    
    // MARK: - Custom Functions
    func navigateToSignUp() {
        let signUpVC = controllerContainer.resolve(SignUpVC.self)!
        show(signUpVC, sender: nil)
    }
    
    // MARK: - Actions
    @IBAction func signInButtonTap(_ sender: UIButton) {
        if sender.tag == 7 {
            AnalyticsManger.shared.onboadringOpenScreen(page: pageControl.selectedIndex + 1, tapSignIn: true)
        } else {
            AnalyticsManger.shared.signInButtonPressed()
        }
        let signInVC = SignInVC()
        navigationController?.pushViewController(signInVC)
    }
    
    @IBAction func signUpButtonTap(_ sender: Any) {
        AnalyticsManger.shared.signUpButtonPressed()
        self.navigateToSignUp()
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        let indexNext = self.welcomePageVC.currentPage + 1
        AnalyticsManger.shared.onboadringOpenScreen(page: indexNext + 1)
        self.welcomePageVC.currentPage = indexNext
        self.welcomePageVC.showActionButtons(indexNext)
        self.pageControl.selectedIndex = indexNext
    }
    
    @IBAction func tapped(_ sender: Any) {
        appLiked()
    }
}
