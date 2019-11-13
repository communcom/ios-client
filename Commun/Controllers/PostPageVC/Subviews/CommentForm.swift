//
//  CommentForm.swift
//  Commun
//
//  Created by Chung Tran on 11/11/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class CommentForm: MyView {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    lazy var textView: CommentTextView = {
        let textView = CommentTextView(forExpandable: ())
        textView.placeholder = "add a comment".localized().uppercaseFirst + "..."
        textView.backgroundColor = .f3f5fa
        textView.cornerRadius = 35 / 2
        return textView
    }()
    lazy var sendButton = CommunButton.circle(size: 35, backgroundColor: .appMainColor, tintColor: .white, imageName: "send", imageEdgeInsets: UIEdgeInsets(inset: 10))
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        addSubview(avatarImageView)
        avatarImageView.autoPinBottomAndLeadingToSuperView(inset: 10, xInset: 16)
        avatarImageView.observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        
        addSubview(textView)
        textView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 5)
        textView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        textView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        addSubview(sendButton)
        sendButton.autoPinEdge(.leading, to: .trailing, of: textView, withOffset: 5)
        sendButton.autoPinBottomAndTrailingToSuperView(inset: 10, xInset: 16)
        
        bind()
    }
    
    func bind() {
        // setup observer
        let isTextViewEmpty = textView.rx.text.orEmpty
            .map{$0 == ""}
            .distinctUntilChanged()
        
        #warning("bind imageViewIsEmpty")
        isTextViewEmpty
            .subscribe(onNext: { (isEmpty) in
                if isEmpty {
                    self.sendButton.isEnabled = false
                    self.avatarImageView.widthConstraint?.constant = 35
                } else {
                    self.sendButton.isEnabled = true
                    self.avatarImageView.widthConstraint?.constant = 0
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
//        Observable.combineLatest(isTextViewEmpty, imageView.rx.isEmpty)
//            .map {$0 && $1}
//            .distinctUntilChanged()
//            .subscribe(onNext: {isEmpty in
//                if isEmpty {
//                    self.textFieldToSendBtnConstraint.constant = 0
//                    self.sendBtnWidthConstraint.constant = 0
//                } else {
//                    self.textFieldToSendBtnConstraint.constant = 16
//                    self.sendBtnWidthConstraint.constant = 36
//                }
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.layoutIfNeeded()
//                })
//            })
//            .disposed(by: bag)
//
//        // observe image
//        imageView.rx.isEmpty
//            .map {$0 ? 0: 85}
//            .bind(to: imageWrapperHeightConstraint.rx.constant)
//            .disposed(by: bag)
        
    }
    
    #warning("support image posting")
}
