//
//  UIViewControllerExtension.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

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
}
