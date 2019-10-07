//
//  BasicEditorTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class BasicEditorTextView: ContentTextView {
    override var defaultTypingAttributes: [NSAttributedString.Key : Any] {
        return [.font: UIFont.systemFont(ofSize: 17)]
    }
    
    override var draftKey: String { "BasicEditorTextView.draftKey" }
    
    override var acceptedPostType: String {
        return "basic"
    }
    
    override var canContainAttachments: Bool {
        return false
    }
    
}
