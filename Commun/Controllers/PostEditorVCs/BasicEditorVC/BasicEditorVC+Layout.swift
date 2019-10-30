//
//  BasicEditorVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 10/15/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    override func layoutTopContentTextView() {
        contentTextView.autoPinEdge(.top, to: .bottom, of: communityAvatarImage, withOffset: 20)
    }
    
    override func layoutBottomContentTextView() {
        contentTextView.autoPinEdge(toSuperviewEdge: .bottom)
    }
}
