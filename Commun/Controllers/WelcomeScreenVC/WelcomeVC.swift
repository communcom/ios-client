//
//  WelcomeVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import SwiftTheme

class WelcomeVC: UIViewController {
    // MARK: - Properties
    var welcomePageVC: WelcomePageVC!
    lazy var pageControl = CMPageControll(numberOfPages: 4)

    
    // MARK: - IBOutlets
    @IBOutlet weak var nextButton: StepButton!
    
    @IBOutlet weak var bottomSignInButton: StepButton! {
        didSet {
            self.bottomSignInButton.commonInit(backgroundColor:     UIColor(hexString: "#F3F5FA"),
                                               font:                .boldSystemFont(ofSize: CGFloat.adaptive(width: 15.0)),
                                               cornerRadius:        self.bottomSignInButton.height / CGFloat.adaptive(height: 2.0))
            
            self.bottomSignInButton.setTitleColor(UIColor(hexString: "#6A80F5"), for: .normal)
            self.bottomSignInButton.isHidden = true
        }
    }

    @IBOutlet weak var topSignInButton: BlankButton! {
        didSet {
            self.topSignInButton.commonInit(hexColors:      [blackWhiteColorPickers, grayishBluePickers, grayishBluePickers, grayishBluePickers],
                                            font:           UIFont(name: "SFProText-Medium", size: .adaptive(width: 15.0)),
                                            alignment:      .right)
        }
    }
    
    @IBOutlet var actionButtonsCollection: [StepButton]! {
        didSet {
            self.actionButtonsCollection.forEach {
                $0.commonInit(backgroundColor: UIColor(hexString: "#6A80F5"),
                              font:            .boldSystemFont(ofSize: CGFloat.adaptive(width: 15.0)),
                              cornerRadius:    $0.height / CGFloat.adaptive(height: 2.0))
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
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        view.addSubview(pageControl)
        pageControl.autoAlignAxis(.horizontal, toSameAxisOf: topSignInButton)
        pageControl.autoAlignAxis(toSuperviewAxis: .vertical)
        pageControl.selectedIndex = 0
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
    @IBAction func signInButtonTap(_ sender: Any) {
        let signInVC = controllerContainer.resolve(SignInViewController.self)!
        
        signInVC.handlerSignUp = { [weak self] success in
            guard let strongSelf = self else { return }
            
            if success {
                strongSelf.navigateToSignUp()
            }
        }
        
        navigationController?.pushViewController(signInVC)
    }
    
    @IBAction func signUpButtonTap(_ sender: Any) {
        self.navigateToSignUp()
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        let indexNext = self.welcomePageVC.currentPage + 1
        self.welcomePageVC.currentPage = indexNext
        self.welcomePageVC.showActionButtons(indexNext)
        self.welcomePageVC.timer?.invalidate()
//        self.welcomePageVC.setUpCountDown()
        self.pageControl.selectedIndex = indexNext
    }
    
    
    // MARK: - TESTED
    @IBAction func testButtonTapped(_ sender: Any) {
//        let masterPassvordVC = controllerContainer.resolve(MasterPasswordViewController.self)!
//        navigationController?.pushViewController(masterPassvordVC)
    }
}
