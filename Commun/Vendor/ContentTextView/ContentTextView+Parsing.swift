//
//  ContentTextView+Parsing.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

extension ContentTextView {
    func parseContentBlock(_ block: ResponseAPIContentBlock) -> Completable {
        let attributedText = block.toAttributedString(
            currentAttributes: typingAttributes,
            attachmentType: TextAttachment.self)
        // Asign raw value first
        self.attributedText = attributedText
        
        // Parse attachments
        return parseAttachments()
            .do(onCompleted: { [weak self] in
                self?.originalAttributedString = self?.attributedText
            })
    }
}
