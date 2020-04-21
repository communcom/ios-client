//
//  SwipeNavigationController.swift
//  Commun
//
//  Created by Chung Tran on 8/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    weak var tabBarVC: TabBarVC?
    private var statusBarStyle: UIStatusBarStyle = .default

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {self.statusBarStyle}

    func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        self.statusBarStyle = style
        setNeedsStatusBarAppearanceUpdate()
    }
    
    var previousController: UIViewController? {
        if viewControllers.count > 1 {
            return viewControllers[viewControllers.count-2]
        }
        return nil
    }

    // MARK: - Init

    init(rootViewController: UIViewController, tabBarVC: TabBarVC? = nil) {
        self.tabBarVC = tabBarVC
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func avoidTabBar(viewController: UIViewController) {
        if let scrollView = viewController.view.subviews.first(where: {$0 is UIScrollView}) as? UIScrollView,
            viewController.view.constraints.first(where: {constraint in
                ((constraint.firstItem as? UIView) == scrollView || (constraint.secondItem as? UIView) == scrollView) &&
                (constraint.firstAttribute == .bottom && constraint.secondAttribute == .bottom)
            }) != nil {
            let bottomOffset: CGFloat = 10
            let bottomInset = scrollView.contentInset.bottom + bottomOffset + tabBarHeight
            scrollView.contentInset.bottom = bottomInset
        }
    }
    
    // MARK: - Overrides
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        avoidTabBar(viewController: viewController)
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if let vc = previousController as? BaseViewController {
            vc.configureNavigationBar()
            vc.changeStatusBarStyle(vc.preferredStatusBarStyle)
        }
        
        return super.popViewController(animated: animated)
    }
}
