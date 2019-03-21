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
        showAlert(title: "TODO", message: "Переход на EditorPage")
    }
    
    func editorWidgetDidTapMediaButton() {
        showAlert(title: "TODO", message: "Открытие галереи")
    }
    
}
