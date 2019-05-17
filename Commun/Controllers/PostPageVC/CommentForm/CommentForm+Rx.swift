//
//  CommentForm+Rx.swift
//  Commun
//
//  Created by Chung Tran on 17/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: CommentForm {
    var didSubmit: Observable<String> {
        return base.sendButton.rx.tap
            .withLatestFrom(base.textView.rx.text.orEmpty)
    }
}
