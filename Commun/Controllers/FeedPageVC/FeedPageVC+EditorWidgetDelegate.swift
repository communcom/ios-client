//
//  FeedPageVC+EditorWidgetDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension FeedPageVC: EditorWidgetDelegate {
    
    func editorWidgetDidTapInputButton() {
        let editorVC = controllerContainer.resolve(EditorPageVC.self)
        let nav = UINavigationController(rootViewController: editorVC!)
        present(nav, animated: true, completion: nil)
    }
    
    func editorWidgetDidTapMediaButton() {
        showAlert(title: "TODO", message: "Открытие галереи")
    }
    
}
