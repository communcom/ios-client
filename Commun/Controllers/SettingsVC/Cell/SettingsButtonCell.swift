//
//  ChangePasswordCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol SettingsButtonCellDelegate {
    func buttonDidTap(on cell: SettingsButtonCell)
}

class SettingsButtonCell: UITableViewCell {
    enum ButtonType {
        case changeAllPassword
        case logout
    }
    
    @IBOutlet weak var button: UIButton!
    var delegate: SettingsButtonCellDelegate?
    var type: ButtonType?
    
    func setUpWithButtonType(_ type: ButtonType) {
        self.type = type
        switch type {
        case .changeAllPassword:
            button.setTitle("Change all password".localized(), for: .normal)
            button.setTitleColor(.appMainColor, for: .normal)
        case .logout:
            button.setTitle("Log out".localized(), for: .normal)
            button.setTitleColor(.red, for: .normal)
        }
    }
    
    @IBAction func changePasswordButtonTap(_ sender: Any) {
        guard let type = type else {return}
        switch type {
        case .changeAllPassword:
            let alert = UIAlertController(title: "Change all password",
                                          message: "Changing passwords will save your wallet if someone saw your password.",
                                          preferredStyle: .alert)
            alert.addTextField { field in
                field.placeholder = "Paste owner password"
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                print("Update password")
            }))
            
            parentViewController?.present(alert, animated: true, completion: nil)
        case .logout:
            parentViewController?.showAlert(title: "Logout".localized(), message: "Do you really want to logout?".localized(), buttonTitles: ["Ok".localized(), "Cancel".localized()], highlightedButtonIndex: 1) { (index) in
                
                if index == 0 {
                    do {
                        try CurrentUser.logout()
                        AppDelegate.reloadSubject.onNext(true)
                    } catch {
                        self.parentViewController?.showError(error)
                    }
                }
            }
        }
        delegate?.buttonDidTap(on: self)
    }
}
