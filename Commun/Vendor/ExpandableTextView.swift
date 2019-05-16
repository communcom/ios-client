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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.rx.didChange
            .subscribe(onNext: {_ in
                var newFrame = self.frame
                let width = newFrame.size.width
                let newSize = self.sizeThatFits(CGSize(width: width,
                                                           height: CGFloat.greatestFiniteMagnitude))
                newFrame.size = CGSize(width: width, height: newSize.height)
                self.frame = newFrame
                
                self.heightConstraint.constant = newSize.height
                self.layoutIfNeeded()
            })
            .disposed(by: bag)
    }
    
    func setDelegate(_ delegate: UIScrollViewDelegate) {
        self.rx.setDelegate(delegate)
            .disposed(by: bag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        // Create heightConstraint if not existed
        if heightConstraint == nil {
            // Create heightConstraint
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 38)
            self.addConstraint(heightConstraint)
        }
        
        // Set content inset
        textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
}
