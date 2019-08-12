//
//  SettingsVC+ButtonDelegate.swift
//  Commun
//
//  Created by Chung Tran on 7/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension SettingsVC: SettingsButtonCellDelegate {
    enum ButtonType: String {
        case showAllPasswords = "Show all passwords"
        case changeAllPasswords = "Change all passwords"
        case logout = "Logout"
        
        var rendered: SettingsButtonCell.ButtonType {
            var titleColor = UIColor.appMainColor
            if self == .logout {
                titleColor = .red
            }
            return (title: rawValue, titleColor: titleColor)
        }
    }
    
    func buttonDidTap(on cell: SettingsButtonCell) {
        guard let cellType = cell.type,
            let buttonType = ButtonType(rawValue: cellType.title)
        else {return}
        
        switch buttonType {
        case .showAllPasswords:
            // TODO: Authentication
            let vc = LocalAuthVC()
            vc.canIgnore = true
            vc.completion = {
                self.viewModel.showKey.accept(true)
            }
            let nc = UINavigationController(rootViewController: vc)
            present(nc, animated: true, completion: nil)
            break
        case .changeAllPasswords:
            let alert = UIAlertController(title:            "Change all passwords",
                                          message:          "Changing passwords will save your wallet if someone saw your password.",
                                          preferredStyle:   .alert)
            alert.addTextField { field in
                field.placeholder = "Paste owner password"
            }
            
            alert.addAction(UIAlertAction(title: "cancel".localized().uppercaseFirst, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                // TODO: Update password
                print("Update password")
            }))
            
            present(alert, animated: true, completion: nil)
        case .logout:
            showAlert(title: "Logout".localized(), message: "Do you really want to logout?".localized(), buttonTitles: ["Ok".localized(), "cancel".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
                
                if index == 0 {
                    self.showIndetermineHudWithMessage("logging out".localized().uppercaseFirst)
                    RestAPIManager.instance.rx.logout()
                        .subscribe(onCompleted: {
                            self.hideHud()
                            AppDelegate.reloadSubject.onNext(true)
                        }, onError: { (error) in
                            self.hideHud()
                            self.showError(error)
                        })
                        .disposed(by: self.bag)
                }
            }
        }
    }
}
