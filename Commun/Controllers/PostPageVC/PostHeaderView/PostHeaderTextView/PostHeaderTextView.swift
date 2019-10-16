//
//  PostHeaderTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/16/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import SubviewAttachingTextView

class PostHeaderTextView: SubviewAttachingTextView {
    lazy var attachmentSize: CGSize = {
        let width = size.width - textContainerInset.left - textContainerInset.right - 3
        return CGSize(width: width, height: 238 * width / size.width)
    }()
    let defaultFont = UIFont.systemFont(ofSize: 17)
    
    var defaultTypingAttributes: [NSAttributedString.Key : Any] {
        return [.font: defaultFont]
    }
}
