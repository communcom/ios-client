//
//  ContentTextView+Parsing.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ContentTextView {
    func parseText(_ string: String) {
        // Plain string
        var attributedText = NSAttributedString(string: string, attributes: defaultTypingAttributes)
        originalAttributedString = attributedText
        
        // Parse data
        if let jsonData = string.data(using: .utf8),
            let block = try? JSONDecoder().decode(ContentBlock.self, from: jsonData)
        {
            attributedText = block.toAttributedString(currentAttributes: typingAttributes)
        }
        
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
