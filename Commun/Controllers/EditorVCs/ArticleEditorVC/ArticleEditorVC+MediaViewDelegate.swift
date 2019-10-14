//
//  ArticleEditorVC+MediaViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/14/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ArticleEditorVC: AttachmentViewDelegate {
    func attachmentViewCloseButtonDidTouch(_ attachmentView: AttachmentView) {
        print("close")
    }
}
