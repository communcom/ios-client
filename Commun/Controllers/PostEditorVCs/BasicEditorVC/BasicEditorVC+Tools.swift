//
//  BasicEditorVC+Tools.swift
//  Commun
//
//  Created by Chung Tran on 10/15/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    override func addArticle() {
        let showArticleVC = {[weak self] in
            weak var presentingViewController = self?.presentingViewController
            let attrStr = self?.contentTextView.attributedText
            self?.dismiss(animated: true, completion: {
                let vc = ArticleEditorVC()
                vc.modalPresentationStyle = .fullScreen
                presentingViewController?.present(vc, animated: true, completion: {
                    vc.contentTextView.attributedText = attrStr
                })
            })
        }
        
        if contentTextView.text.isEmpty {
            showArticleVC()
        } else {
            showAlert(title: "add article".localized().uppercaseFirst, message: "override current work and add a new article".localized().uppercaseFirst + "?", buttonTitles: ["OK".localized(), "cancel".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    showArticleVC()
                }
            }
        }
    }
}
