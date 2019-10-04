//
//  BasicEditorTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class BasicEditorTextView: ContentTextView {
    override var defaultTypingAttributes: [NSAttributedString.Key : Any] {
        return [.font: UIFont.systemFont(ofSize: 17)]
    }
    
    let draftKey = "BasicEditorTextView.draftKey"
    
    
}
