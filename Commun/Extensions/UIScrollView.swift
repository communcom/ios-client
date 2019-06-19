//
//  UIScrollView.swift
//  Commun
//
//  Created by Chung Tran on 07/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

extension UIScrollView {
    func scrollsToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: true)
    }
}

extension Reactive where Base: UIScrollView {
    var willDragDown: Observable<Bool> {
        return Observable.merge(
            willEndDragging.map { $0.velocity.y >= 0 },
            contentOffset.map {($0.y + self.base.contentInset.top) == 0 }.filter {$0}.map{!$0}
        )
    }
}
