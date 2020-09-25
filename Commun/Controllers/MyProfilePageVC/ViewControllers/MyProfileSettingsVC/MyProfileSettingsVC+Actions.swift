//
//  MyProfileSettingsVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension MyProfileSettingsVC {
    @objc func actionViewDidTouch(_ tap: CMActionSheet.TapGesture) {
        guard let action = tap.action else {return}
        action.handle?()
    }
    
    @objc func showEditProfile() {
        let profileEditVC = MyProfileDetailVC()
        navigationController?.pushViewController(profileEditVC)
    }

    @objc func selectLanguage() {
        let navVC = SwipeNavigationController(rootViewController: SelectInterfaceLanguageVC())
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func showNotificationSettings() {
        let navVC = SwipeNavigationController(rootViewController: NotificationsSettingsVC())
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func showPassword() {
        show(PasswordsVC(), sender: nil)
    }
    
    @objc func logout() {
        showAlert(title: "logout".localized().uppercaseFirst, message: "do you really want to logout?".localized().uppercaseFirst, buttonTitles: ["Ok".localized(), "cancel".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
            
            if index == 0 {
                AuthManager.shared.logout()
            }
        }
    }
}
