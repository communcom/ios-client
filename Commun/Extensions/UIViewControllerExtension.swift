//
//  UIViewControllerExtension.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import MBProgressHUD

protocol NextButtonBottomConstraint {
    var nextButtonBottomConstraint: NSLayoutConstraint! { get set }
}

extension UIViewController {
    class func instanceController(fromStoryboard storyboard: String, withIdentifier identifier: String) -> UIViewController {
        let st = UIStoryboard(name: storyboard, bundle: nil)
        return st.instantiateViewController(withIdentifier: identifier)
    }
    
    func showActionSheet(title: String? = nil, message: String? = nil, actions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for action in actions {
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showGeneralError() {
        showErrorWithLocalizedMessage("Something went wrong.\nPlease try again later")
    }
    
    func showErrorWithLocalizedMessage(_ message: String) {
        showAlert(title: "Error".localized(), message: message.localized())
    }
    
    func showError(_ error: Error) {
        var message = error.localizedDescription
        if let error = error as? ErrorAPI {
            message = error.caseInfo.message
        }
        showAlert(title: "Error".localized(), message: message.localized())
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: self.view, animated: false)
    }
    
    func showIndetermineHudWithMessage(_ message: String) {
        // Hide all previous hud
        hideHud()
        
        // show new hud
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.isUserInteractionEnabled = true
        hud.label.text = message
        hud.backgroundColor = UIColor(white: 0, alpha: 0.2)

    }
    
    var isModal: Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func showProfileWithUserId(_ userId: String) {
        // if profile was opened, shake it off!!
        if let profileVC = self as? ProfilePageVC, profileVC.viewModel.userId == userId {
            profileVC.view.shake()
            return
        }
        
        // Open other user's profile
        if userId != Config.currentUser?.id {
            let profile = controllerContainer.resolve(ProfilePageVC.self)!
            profile.viewModel = ProfilePageViewModel()
            profile.viewModel.userId = userId
            show(profile, sender: nil)
            return
        }
        
        // open profile tabbar
        if let profileNC = tabBarController?.viewControllers?.first(where: {$0.tabBarItem.tag == 2}),
            profileNC != tabBarController?.selectedViewController{
            
            UIView.transition(from: tabBarController!.selectedViewController!.view, to: profileNC.view, duration: 0.3, options: UIView.AnimationOptions.transitionFlipFromLeft, completion: nil)
            
            tabBarController?.selectedViewController = profileNC
        }
    }
    
    // MARK: - ChildVC
    func add(_ child: UIViewController, to view: UIView? = nil) {
        addChild(child)
        
        if let frame = view?.frame {
            child.view.frame = frame
        }
        
        view?.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
