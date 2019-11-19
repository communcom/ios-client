//
//  ContentTextView+Parsing.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension ContentTextView {
    func parseContentBlock(_ block: ResponseAPIContentBlock) {
        let attributedText = block.toAttributedString(
            currentAttributes: typingAttributes,
            attachmentType: TextAttachment.self)
        // Asign raw value first
        self.attributedText = attributedText
        
        // Parse attachments
        parseAttachments()
            .do(onSubscribe: {
                self.parentViewController?
                    .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            })
            .subscribe(onCompleted: { [weak self] in
                self?.parentViewController?.hideHud()
                self?.originalAttributedString = self?.attributedText
            }) { [weak self] (error) in
                self?.parentViewController?.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
