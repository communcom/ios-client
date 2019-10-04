//
//  BasicEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout

class BasicEditorVC: EditorVC {
    // MARK: - Subviews
    var contentTextView = ContentTextView(height: 47.5)
    var contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    
    override func layoutContentView() {
        super.layoutContentView()
        
        // textView
        contentView.addSubview(contentTextView)
        contentTextView.placeholder = "enter text".localized().uppercaseFirst + "..."
        contentTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        contentTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        contentTextView.autoPinEdge(.top, to: .bottom, of: communityAvatarImage, withOffset: 20)
        
        // countlabel
        contentView.addSubview(contentTextViewCountLabel)
        contentTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 8)
        contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
    }
    
    override func pinContentViewBottom() {
        contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
}
