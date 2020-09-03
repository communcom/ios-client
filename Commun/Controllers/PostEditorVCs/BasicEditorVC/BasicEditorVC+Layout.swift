//
//  BasicEditorVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 10/15/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    override func layoutBottomContentTextView() {
        contentView.addSubview(attachmentView)
        attachmentView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        attachmentView.autoPinEdge(.top, to: .bottom, of: contentTextViewCountLabel, withOffset: 16)
        attachmentView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 16)
            .isActive = true
        
        contentTextView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 16)
            .isActive = true
    }
}
