//
//  ExpandableTextView.swift
//  Commun
//
//  Created by Chung Tran on 16/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ExpandableTextView: UITextView {
    private let bag = DisposeBag()
    var heightConstraint: NSLayoutConstraint!
    
    @IBInspectable var maxHeight: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.rx.text
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: {_ in
                var newFrame = self.frame
                let width = newFrame.size.width
                let newSize = self.sizeThatFits(CGSize(width: width,
                                                           height: CGFloat.greatestFiniteMagnitude))
                newFrame.size = CGSize(width: max(newSize.width, width), height: newSize.height)
                if (self.maxHeight > 0 && newFrame.size.height > self.maxHeight) {return}
                self.frame = newFrame
                self.heightConstraint.constant = newSize.height
                self.layoutIfNeeded()
            })
            .disposed(by: bag)
        
        heightConstraint = constraints.first {$0.firstAttribute == .height}
        textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    func setDelegate(_ delegate: UIScrollViewDelegate) {
        self.rx.setDelegate(delegate)
            .disposed(by: bag)
    }
}
