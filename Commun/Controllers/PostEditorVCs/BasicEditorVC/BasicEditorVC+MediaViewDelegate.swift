//
//  BasicEditorVC+MediaViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/14/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    override func attachmentViewCloseButtonDidTouch(_ attachmentView: AttachmentView) {
        self._viewModel.attachment.accept(nil)
        self.link = nil
    }
}
