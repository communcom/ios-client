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
    enum NavigationBarType {
        case normal(translucent: Bool = false, backgroundColor: UIColor = .white, font: UIFont = .boldSystemFont(ofSize: 15), textColor: UIColor = .black)
        case hidden
    }
    
    // MARK: - Properties
    lazy var disposeBag = DisposeBag()
    var navigationBarType: NavigationBarType {.normal()}
    
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
        
        configureNavigationBarType()
    }
    
    func configureNavigationBarType() {
        switch navigationBarType {
        case .normal(let translucent, let backgroundColor, let font, let textColor):
            navigationController?.navigationBar.isTranslucent = translucent
            let img = UIImage()
            navigationController?.navigationBar.setBackgroundImage(img, for: .default)
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.barTintColor = backgroundColor
            navigationController?.navigationBar.subviews.first?.backgroundColor = backgroundColor
            
            navigationController?.navigationBar.tintColor = textColor
            navigationController?.navigationBar.setTitleFont(font, color: textColor)
            navigationController?.setNavigationBarHidden(false, animated: false)
        case .hidden:
            navigationController?.setNavigationBarHidden(true, animated: false)
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
    
    func setTabBarHidden(_ value: Bool) {
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
