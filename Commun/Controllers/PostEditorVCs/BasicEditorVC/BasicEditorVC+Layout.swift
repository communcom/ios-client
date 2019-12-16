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
        contentTextView.autoPinEdge(.top, to: .bottom, of: communityView, withOffset: 5)
    }
    
    override func layoutBottomContentTextView() {
        contentView.addSubview(attachmentView)
        attachmentView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        attachmentView.autoPinEdge(.top, to: .bottom, of: contentTextViewCountLabel, withOffset: 16)
        attachmentView.autoPinEdge(toSuperviewEdge: .bottom)
    }
}
