//
//  EditorPageTextView+Binding.swift
//  Commun
//
//  Created by Chung Tran on 9/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorPageTextView {
    func bind() {
        rx.didChangeSelection
            .subscribe(onNext: {
                // get TextStyle at current selectedRange
                self.setCurrentTextStyle()
            })
            .disposed(by: bag)
        
        rx.didChange
            .subscribe(onNext: {
                self.resolveHashTags()
                self.resolveMentions()
                self.resolveLinks()
                
                // reset
                if self.attributedText.length == 0 {
                    self.clearFormatting()
                }
            })
            .disposed(by: bag)
    }
}
