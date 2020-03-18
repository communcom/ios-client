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

class BaseViewController: UIViewController {
    // MARK: - Properties
    lazy var disposeBag = DisposeBag()
    var shouldHideNavigationBar: Bool {false}
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setUp()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldHideNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldHideNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    // MARK: - Custom Functions
    func setUp() {
        
    }
    
    func bind() {
        
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
