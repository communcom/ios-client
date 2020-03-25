//
//  WelcomeVC.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WelcomeVC: BaseViewController {
    override var shouldHideNavigationBar: Bool {true}
    let numberOfPages = 3
    
    // MARK: - Properties
    lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    // MARK: - Subviews
    lazy var topSignInButton = UIButton(label: "sign in".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .semibold), textColor: .appMainColor)
    lazy var pageControl = CMPageControll(numberOfPages: 3)
    lazy var containerView = UIView(forAutoLayout: ())
    lazy var buttonStackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fillEqually)
    
    lazy var nextButton = CommunButton.default(height: 50, label: "next".localized().uppercaseFirst, isHuggingContent: false)
    lazy var bottomSignInButton = UIButton(height: 50, label: "sign in".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .semibold), backgroundColor: .f3f5fa, textColor: .appMainColor, cornerRadius: 25)
    lazy var signUpButton = CommunButton.default(height: 50, label: "sign up".localized().uppercaseFirst, isHuggingContent: false)
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.autoPinEdgesToSuperviewEdges()
        containerView.setNeedsLayout()
    }
    
    override func setUp() {
        super.setUp()
        // navigation bar
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        navigationBarAppearace.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: .adaptive(width: 30), weight: .bold)
        ]
        
        // if signUp is processing
        if KeychainManager.currentUser()?.registrationStep != nil
        {
            navigateToSignUp()
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // top sign in button
        view.addSubview(topSignInButton)
        topSignInButton.autoPinTopAndTrailingToSuperViewSafeArea(inset: 0, xInset: 16)
        topSignInButton.addTarget(self, action: #selector(signInButtonTap(_:)), for: .touchUpInside)
        
        // page control
        view.addSubview(pageControl)
        pageControl.autoAlignAxis(.horizontal, toSameAxisOf: topSignInButton)
        pageControl.autoAlignAxis(toSuperviewAxis: .vertical)
        
        pageControl.selectedIndex = 0
        
        // button stack view
        view.addSubview(buttonStackView)
        buttonStackView.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 16)
        buttonStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        buttonStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        buttonStackView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        buttonStackView.addArrangedSubviews([
            nextButton,
            signUpButton,
            bottomSignInButton
        ])
        
        bottomSignInButton.addTarget(self, action: #selector(signInButtonTap(_:)), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signInButtonTap(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTap(_:)), for: .touchUpInside)
        
        // container view
        view.addSubview(containerView)
        containerView.autoPinEdge(.top, to: .bottom, of: pageControl, withOffset: 16)
        containerView.autoPinEdge(.bottom, to: .top, of: buttonStackView, withOffset: -16)
        containerView.autoPinEdge(toSuperviewEdge: .leading)
        containerView.autoPinEdge(toSuperviewEdge: .trailing)
        
        // add pageVC
        pageVC.dataSource = self
        addChild(pageVC)
        containerView.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        kickOff()
    }
    
    // MARK: - Actions
    private func kickOff() {
        let firstVC = WelcomeItemVC(index: 0)
        pageVC.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
    }
    
    func navigateToSignUp() {
        let controller = SignUpVC()
        show(controller, sender: nil)
    }
    
    @objc func signInButtonTap(_ sender: UIButton) {
        if sender == topSignInButton {
            AnalyticsManger.shared.onboadringOpenScreen(page: pageControl.selectedIndex + 1, tapSignIn: true)
        } else {
            AnalyticsManger.shared.signInButtonPressed()
        }
        let signInVC = SignInVC()
        navigationController?.pushViewController(signInVC)
    }
    
    @objc func signUpButtonTap(_ sender: Any) {
        AnalyticsManger.shared.signUpButtonPressed()
        self.navigateToSignUp()
    }
    
    @objc func nextButtonTap(_ sender: Any) {
//        let indexNext = pageVC.currentPage + 1
//        AnalyticsManger.shared.onboadringOpenScreen(page: indexNext + 1)
//        pageVC.currentPage = indexNext
//        pageVC.showActionButtons(indexNext)
//        pageControl.selectedIndex = indexNext
    }
}

extension WelcomeVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WelcomeItemVC,
            vc.index != 0
        else {return nil}
        return WelcomeItemVC(index: vc.index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WelcomeItemVC,
            vc.index < numberOfPages - 1
        else {return nil}
        return WelcomeItemVC(index: vc.index + 1)
    }
}
