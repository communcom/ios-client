//
//  MyProfileSettingsVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension MyProfileSettingsVC {
    @objc func actionViewDidTouch(_ tap: CommunActionSheet.Action.TapGesture) {
        guard let action = tap.action else {return}
        action.handle?()
    }
    
        @objc func showEditProfile() {
            let profileEditVC = controllerContainer.resolve(ProfileEditViewController.self)!
            navigationController?.pushViewController(profileEditVC)
//            let navVC = UINavigationController(rootViewController: ProfileEditViewController())
//            show(navVC, sender: nil)
        }

    @objc func selectLanguage() {
        let navVC = BaseNavigationController(rootViewController: SelectLanguageVC())
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func showNotificationSettings() {
        let navVC = BaseNavigationController(rootViewController: NotificationsSettingsVC())
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func logout() {
        showAlert(title: "Logout".localized(), message: "Do you really want to logout?".localized(), buttonTitles: ["Ok".localized(), "cancel".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
            
            if index == 0 {
                AuthorizationManager.shared.status.accept(.authorizing)
                try! RestAPIManager.instance.logout()
            }
        }
    }
}
