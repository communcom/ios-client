//
//  FeedPageVC+PostCardCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension FeedPageVC: PostCardCellDelegate {
    
    func didTapMenuButton() {
        showAlert(title: "TODO", message: "Нажата кнопка контекстного меню")
    }
    
    func didTapUpButton() {
        showAlert(title: "TODO", message: "Голос вверх")
    }
    
    func didTapDownButton() {
        showAlert(title: "TODO", message: "Голос вниз")
    }
    
    func didTapShareButton() {
        showAlert(title: "TODO", message: "Кнопка шары")
    }
    
    
    
    
}
