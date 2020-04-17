//
//  SignUpVC.swift
//  Commun
//
//  Created by Chung Tran on 3/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SignUpVC: BaseSignUpVC, SignUpRouter {
    // MARK: - Nested type
    struct Method {
        var serviceName: String
        var backgroundColor: UIColor = .clear
        var textColor: UIColor = .appBlackColor
    }
    
    class MethodTapGesture: UITapGestureRecognizer {
        var method: Method?
    }
    
    // MARK: - Constants
    private let phoneServiceName = "phone"
    private let emailServiceName = "email"
    
    // MARK: - Properties
    lazy var methods: [Method] = {
        [Method(serviceName: phoneServiceName), Method(serviceName: emailServiceName)] +
            SocialNetwork.allCases.filter({
                // temp hide sigh up with google
                $0 == .facebook
            }).map { network in
            var backgroundColor: UIColor?
            var textColor: UIColor?
            switch network {
            case .facebook:
                backgroundColor = UIColor(hexString: "#415A94")!
                textColor = .appWhiteColor
//            case .twitter:
//                backgroundColor = UIColor(hexString: "#4AA1EC")!
//                textColor = .appWhiteColor
//            case .apple:
//                backgroundColor = .appBlackColor
//                textColor: .appWhiteColor
            case .google:
                break
            }
            return Method(serviceName: network.rawValue, backgroundColor: backgroundColor ?? .clear, textColor: textColor ?? .appBlackColor)
        }
    }()
    private var isStepChecked = false
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 12, alignment: .center, distribution: .fill)
    
    // MARK: - Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isStepChecked {
            // if signUp is processing
            if let step = KeychainManager.currentUser()?.registrationStep,
                step != .firstStep
            {
                getState(showError: false)
            }
            isStepChecked = true
        }
    }
    
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.openRegistrationSelection()

        // set up stack view
        for method in methods {
            let methodView = UIView(height: 44, backgroundColor: method.backgroundColor, cornerRadius: 6)
            methodView.borderColor = .appGrayColor
            methodView.borderWidth = 1
            
            let imageView = UIImageView(width: 30, height: 30, imageNamed: "sign-up-with-\(method.serviceName)")
            methodView.addSubview(imageView)
            imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 7), excludingEdge: .trailing)
            
            let label = UILabel.with(text: "continue with".localized().uppercaseFirst + " " + method.serviceName.localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: method.textColor, textAlignment: .center)
            methodView.addSubview(label)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 7)
            label.autoPinEdge(toSuperviewEdge: .trailing, withInset: 7)
            
            stackView.addArrangedSubview(methodView)
            
            methodView.autoPinEdge(toSuperviewEdge: .leading)
            methodView.autoPinEdge(toSuperviewEdge: .trailing)
            
            methodView.isUserInteractionEnabled = true
            let tap = MethodTapGesture(target: self, action: #selector(methodDidTap(_:)))
            tap.method = method
            methodView.addGestureRecognizer(tap)
        }
        
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdge(toSuperviewEdge: .top, withInset: 51)
        stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: UIScreen.main.isSmall ? 16 : 39)
        stackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: UIScreen.main.isSmall ? 16 : 39)
        
        // terms of use
        scrollView.contentView.addSubview(termOfUseLabel)
        termOfUseLabel.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: .adaptive(height: 30))
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(height: 39))
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(height: 39))
        
        // sign in label
        scrollView.contentView.addSubview(signInLabel)
        signInLabel.topAnchor.constraint(greaterThanOrEqualTo: termOfUseLabel.bottomAnchor, constant: 16)
            .isActive = true
        signInLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(height: 39))
        signInLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(height: 39))
        
        // pin bottom
        signInLabel.autoPinEdge(toSuperviewEdge: .bottom)
        
        let constraint = signInLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    @objc func methodDidTap(_ gesture: MethodTapGesture) {
        guard let method = gesture.method else {return}
        signUpWithMethod(method)
    }

    func signUpWithMethod(_ method: Method) {
        // Sign up with phone
        if method.serviceName == phoneServiceName {
            let signUpVC = SignUpWithPhoneVC()
            AnalyticsManger.shared.registrationOpenScreen(.phone)
            show(signUpVC, sender: nil)
            return
        }
        
        // Sign up with email
        if method.serviceName == emailServiceName {
            let signUpVC = SignUpWithEmailVC()
            AnalyticsManger.shared.registrationOpenScreen(.email)
            show(signUpVC, sender: nil)
            return
        }

        // Sign up via social network
        var manager: SocialLoginManager
        if method.serviceName == SocialNetwork.facebook.rawValue {
            manager = FacebookLoginManager()
            AnalyticsManger.shared.registrationOpenScreen(.facebook)
        } else if method.serviceName == SocialNetwork.google.rawValue {
            manager = GoogleLoginManager()
            AnalyticsManger.shared.registrationOpenScreen(.google)
        } else {
            return
        }

        manager.viewController = self
        manager.login()
            .flatMap { token -> Single<SocialIdentity> in
                self.showIndetermineHudWithMessage("signing you up".localized().uppercaseFirst + "...")
                return manager.getIdentityFromToken(token)
            }
            .subscribe(onSuccess: { (identity) in
                self.hideHud()

                try? KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.setUserName.rawValue,
                    Config.currentUserIdentityKey: identity.identity!
                ])
                
                self.signUpNextStep()
            }, onError: { (error) in
                self.hideHud()
                self.showError(error)
            })
            .disposed(by: disposeBag)
    }
}
