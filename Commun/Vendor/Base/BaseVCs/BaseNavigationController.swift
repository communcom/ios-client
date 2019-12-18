//
//  SwipeNavigationController.swift
//  Commun
//
//  Created by Chung Tran on 8/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

final class BaseNavigationController: UINavigationController {
    weak var tabBarVC: TabBarVC?
    var style: UIStatusBarStyle = .default

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }

    func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        self.style = style
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Init

    init(rootViewController: UIViewController, tabBarVC: TabBarVC? = nil) {
        self.tabBarVC = tabBarVC
        super.init(rootViewController: rootViewController)
        delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This needs to be in here, not in init
        interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // navigationBar
//        navigationBar.addShadow(ofColor: .shadow, offset: CGSize(width: 0, height: 2), opacity: 0.1)
    }
          
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Methods
    func resetNavigationBar() {
        navigationBar.isTranslucent = false
        
        let img = UIImage()
        navigationBar.shadowImage = img
        navigationBar.setBackgroundImage(img, for: .default)
        navigationBar.barStyle = .default
        navigationBar.barTintColor = .white
        navigationBar.subviews.first?.backgroundColor = .white
        navigationBar.tintColor = .black
        navigationBar.setTitleFont(.boldSystemFont(ofSize: 15), color: .black)
        setNavigationBarHidden(false, animated: false)
    }
    
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
    
//    func setStatusBarTintColor(_ color: UIColor) {
//        if #available(iOS 13.0, *) {
//            let navBarAppearance = navigationBar.standardAppearance
//            navBarAppearance.titleTextAttributes = [.foregroundColor: color]
//            navigationBar.standardAppearance = navBarAppearance
//            navigationBar.scrollEdgeAppearance = navBarAppearance
//        }
//        else if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
////            statusBar.backgroundColor = style == .lightContent ? UIColor.black : .white
//            statusBar.setValue(color, forKey: "foregroundColor")
//        }
//    }
    
    // MARK: - Overrides
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true
        resetNavigationBar()
        
        avoidTabBar(viewController: viewController)
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
//        resetNavigationBar()
        return super.popViewController(animated: animated)
    }
    
    // MARK: - Private Properties
    
    fileprivate var duringPushAnimation = false
    
}

// MARK: - UINavigationControllerDelegate

extension BaseNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let swipeNavigationController = navigationController as? BaseNavigationController else { return }
        
        swipeNavigationController.duringPushAnimation = false
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension BaseNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }
        
        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed
        return viewControllers.count > 1 && duringPushAnimation == false
    }
}
