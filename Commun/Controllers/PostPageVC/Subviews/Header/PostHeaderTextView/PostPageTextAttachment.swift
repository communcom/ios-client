//
//  PostPageTextAttachment.swift
//  Commun
//
//  Created by Chung Tran on 11/15/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import SubviewAttachingTextView

final class PostPageTextAttachment: SubviewTextAttachment, TextAttachmentType {
    var view: EmbedView!
    
    convenience init(block: ResponseAPIContentBlock, size: CGSize) {
        let view = EmbedView(content: block, isPostDetail: true)
        view.frame.size.width = size.width
        view.layoutIfNeeded()
        let rightSize = view.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        self.init(view: view, size: rightSize)
        self.view = view
    }
}
