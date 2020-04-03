//
//  BaseViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import SafariServices
//import SwipeTransition

class BaseViewController: UIViewController {
    // MARK: - Nested type
    enum NavigationBarStyle {
        case normal(translucent: Bool = false, backgroundColor: UIColor = .white, font: UIFont = .boldSystemFont(ofSize: 15), textColor: UIColor = .black, prefersLargeTitle: Bool = false)
        case hidden
        case embeded
    }
    
    // MARK: - Properties
    lazy var disposeBag = DisposeBag()
    var prefersNavigationBarStype: NavigationBarStyle {.normal()}
    var shouldHideTabBar: Bool {false}
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setUp()
        
        bind()
        
//        backSwipe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
        
        if shouldHideTabBar {
            setTabBarHidden(true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if shouldHideTabBar {
            setTabBarHidden(false)
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        // reset navigation bar after poping
        if parent == nil,
            let vc = baseNavigationController?.previousController as? BaseViewController
        {
            vc.configureNavigationBar()
        }
    }
    
    func configureNavigationBar() {
        switch prefersNavigationBarStype {
        case .normal(let translucent, let backgroundColor, let font, let textColor, let prefersLargeTitle):
            navigationController?.navigationBar.isTranslucent = translucent
            let img = UIImage()
            navigationController?.navigationBar.setBackgroundImage(img, for: .default)
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.barTintColor = backgroundColor
            navigationController?.navigationBar.subviews.first?.backgroundColor = backgroundColor
            
            // set title style
            navigationController?.navigationBar.tintColor = textColor
            navigationController?.navigationBar.setTitleFont(font, color: textColor)
            navigationController?.setNavigationBarHidden(false, animated: false)
            
            // remove navigationBar default shadow
            let img2 = UIImage()
            navigationController?.navigationBar.shadowImage = img2
            
            navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitle
        case .hidden:
            navigationController?.setNavigationBarHidden(true, animated: false)
        case .embeded:
            break
        }
        
        view.superview?.layoutIfNeeded()
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
        tabBarController?.tabBar.isHidden = true
        if let tabBarVC = tabBarController as? TabBarVC {
            tabBarVC.setTabBarHiden(value)
        }
    }
    
    func load(url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let safariVC = SFSafariViewController(url: url, configuration: config)
            safariVC.delegate = self

            present(safariVC, animated: true)
        }
    }
}

// MARK: - SFSafariViewControllerDelegate
extension BaseViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if !isModal {
            dismiss(animated: true, completion: nil)
        }
    }
}
