//
//  BaseViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import SwiftTheme
import SafariServices

class BaseViewController: UIViewController {
    // MARK: - Properties
    lazy var disposeBag = DisposeBag()
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setUp()
        
        bind()
    }
    
    // MARK: - Custom Functions
    func setUp() {
        
    }
    
    func bind() {
        
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
    
//    func avoidTabBar() {
//        // avoid tabBar
//        guard let scrollView = contentScrollView,
//            let tabBarController = tabBarController as? TabBarVC else {return}
//        var contentInsets = scrollView.contentInset
//        let insetsBottom = contentInsets.bottom + tabBarController.tabBarHeight
//        let defaultBottomOffset: CGFloat = 10
//        contentInsets.bottom = insetsBottom + defaultBottomOffset + view.safeAreaInsets.bottom
//        scrollView.scrollIndicatorInsets.bottom = insetsBottom + view.safeAreaInsets.bottom
//        scrollView.contentInset = contentInsets
//    }
}


// MARK: - SFSafariViewControllerDelegate
extension BaseViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}
