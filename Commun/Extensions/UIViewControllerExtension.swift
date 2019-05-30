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
import ASSpinnerView

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
    
    func showGeneralError() {
        showAlert(title: "Error".localized(), message: "Something went wrong.\nPlease try again later".localized())
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
    
    func showLoading() {
        if self.view.viewWithTag(9999) != nil {return}
        let spinnerView = ASSpinnerView()
        spinnerView.spinnerLineWidth = 6
        spinnerView.spinnerDuration = 0.3
        spinnerView.spinnerStrokeColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1)
        spinnerView.tag = 9999
        
        self.view.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.view.bringSubviewToFront(spinnerView)
    }
    
    func hideLoading() {
        self.view.viewWithTag(9999)?.removeFromSuperview()
    }
}
