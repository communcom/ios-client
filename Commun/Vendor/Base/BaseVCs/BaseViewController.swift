//
//  BaseViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import SwiftTheme

class BaseViewController: UIViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    
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
