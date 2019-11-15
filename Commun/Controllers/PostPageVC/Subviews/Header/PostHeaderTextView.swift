//
//  PostHeaderTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/16/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class PostHeaderTextView: MySubviewAttachingTextView {
    static let attachmentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    lazy var attachmentSize: CGSize = {
        let width = size.width
        return CGSize(width: width, height: 270)
    }()
    let defaultFont = UIFont.systemFont(ofSize: 17)
    
    var defaultAttributes: [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 20
        return [
            .font: defaultFont,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    override func commonInit() {
        super.commonInit()
        textContainerInset = UIEdgeInsets(
            top: 20,
            left: PostHeaderTextView.attachmentInset.left,
            bottom: 0,
            right: PostHeaderTextView.attachmentInset.right)
        textContainer.lineFragmentPadding = 0
        isEditable = false
    }
}

