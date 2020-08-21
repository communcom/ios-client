//
//  BaseViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
//import SwipeTransition

class BaseViewController: UIViewController {
    // MARK: - Nested type
    enum NavigationBarStyle {
        case normal(translucent: Bool = false, backgroundColor: UIColor = .appWhiteColor, font: UIFont = .boldSystemFont(ofSize: 15), textColor: UIColor = .appBlackColor, prefersLargeTitle: Bool = false)
        case hidden
        case embeded
    }
    
    // MARK: - Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {statusBarStyle}
    var prefersNavigationBarStype: NavigationBarStyle {.normal()}
    private var statusBarStyle: UIStatusBarStyle = .default
    
    lazy var disposeBag = DisposeBag()
    var shouldHideTabBar: Bool {false}
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appWhiteColor
        
        setUp()
        
        bind()
        
//        backSwipe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
        changeStatusBarStyle(preferredStatusBarStyle)
        
        setTabBarHidden(shouldHideTabBar)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setTabBarHidden(false)
    }
    
    func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        switch prefersNavigationBarStype {
        case .normal:
            baseNavigationController?.changeStatusBarStyle(style)
        case .hidden:
            self.statusBarStyle = style
            setNeedsStatusBarAppearanceUpdate()
        case .embeded:
            return
        }
    }
    
    func configureNavigationBar() {
        switch prefersNavigationBarStype {
        case .normal(let translucent, let backgroundColor, let font, let textColor, let prefersLargeTitle):
            navigationController?.navigationBar.isTranslucent = translucent
            
            setNavigationBarBackgroundColor(backgroundColor)
            
            // set title style
            setNavigationBarTitleStyle(textColor: textColor, font: font)
            
            // bar buttons
            navigationItem.leftBarButtonItem?.tintColor = textColor
            navigationItem.rightBarButtonItem?.tintColor = textColor
            
            navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitle
            
            navigationController?.setNavigationBarHidden(false, animated: false)
        case .hidden:
            navigationController?.setNavigationBarHidden(true, animated: false)
        case .embeded:
            break
        }
    }
    
    // MARK: - Custom Functions
    func setUp() {
        
    }
    
    func bind() {
        
    }
    
    func backSwipe() {
//        SwipeBackConfiguration.shared = CMSwipeBackConfiguration()
//        SwipeBackConfiguration.shared.parallaxFactor = 0.6
//        SwipeToDismissConfiguration.shared.dismissHeightRatio = 0.3
//
//        switch self {
//        case is WelcomeVC:
//            self.navigationController?.swipeBack?.isEnabled = false
//
//        default:
//            self.navigationController?.swipeBack?.isEnabled = true
//        }
    }
    
    private func setTabBarHidden(_ value: Bool) {
        let vc: UIViewController? = isModal ? presentingViewController : self
        vc?.tabBarController?.tabBar.isHidden = true
        if let tabBarVC = vc?.tabBarController as? TabBarVC {
            tabBarVC.setTabBarHiden(value)
        }
    }
}
