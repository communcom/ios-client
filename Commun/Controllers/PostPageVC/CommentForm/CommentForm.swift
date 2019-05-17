//
//  CommentForm.swift
//  Commun
//
//  Created by Chung Tran on 16/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class CommentForm: UIView {
    private let bag = DisposeBag()
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textView: ExpandableTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textFieldToSendBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtnWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // init view
        Bundle.main.loadNibNamed("CommentForm", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // setup observer
        let isTextViewEmpty = textView.rx.text.orEmpty
            .map{$0 == ""}
            
        isTextViewEmpty.distinctUntilChanged()
            .subscribe(onNext: {isEmpty in
                if isEmpty {
                    self.textFieldToSendBtnConstraint.constant = 0
                    self.sendBtnWidthConstraint.constant = 0
                } else {
                    self.textFieldToSendBtnConstraint.constant = 16
                    self.sendBtnWidthConstraint.constant = 36
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutIfNeeded()
                })
            })
            .disposed(by: bag)
    }
}
