//
//  CommentForm.swift
//  Commun
//
//  Created by Chung Tran on 11/11/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class CommentForm: MyView {
    // MARK: - Edit mode
    enum Mode {
        case new
        case edit
        case reply
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    
    var parentComment: ResponseAPIContentGetComment? {
        didSet {
            setParentComment()
        }
    }
    
    var post: ResponseAPIContentGetPost? {
        didSet {
            viewModel.post = post
        }
    }
    
    var mode: Mode = .new {
        didSet {
            switch mode {
            case .new:
                parentCommentTitleLabel.text = nil
            case .edit:
                parentCommentTitleLabel.text = "edit comment".localized().uppercaseFirst
            case .reply:
                parentCommentTitleLabel.text = "reply to comment".localized().uppercaseFirst
            }
        }
    }
    
    lazy var viewModel = CommentFormViewModel()
    
    
    // MARK: - Subviews
    lazy var parentCommentView = UIView(height: 40, backgroundColor: .white)
    lazy var parentCommentTitleLabel = UILabel.with(text: "Edit comment", textSize: 15, weight: .bold, textColor: .appMainColor)
    lazy var parentCommentLabel = UILabel.with(text: "Amet incididunt enim dolore fugdasd ...", textSize: 13)
    
    lazy var closeParentCommentButton: UIButton = {
        let button = UIButton(width: 24, contentInsets: UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        button.tintColor = .black
        button.setImage(UIImage(named: "close-x"), for: .normal)
        return button
    }()
    
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    
    lazy var textView: CommentTextView = {
        let textView = CommentTextView(forExpandable: ())
        textView.placeholder = "write a comment".localized().uppercaseFirst + "..."
        textView.backgroundColor = .f3f5fa
        textView.cornerRadius = 35 / 2
        textView.tune(withTextColors:   darkGrayishBluePickers,
                      font:             UIFont(name: "SFProText-Medium", size: CGFloat.adaptive(width: 13.0)),
                      alignment:        .left)
        
        return textView
    }()
    
    lazy var sendButton = CommunButton.circle(size:                 44.0,
                                              backgroundColor:      .white,
                                              tintColor:            UIColor(hexString: "#A5A7BD"),
                                              imageName:            "icon-send-comment-gray-defaul",
                                              imageEdgeInsets:      .zero)
    
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        
        // ParentCommentView
        addSubview(parentCommentView)
        parentCommentView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        
        let indicatorView = UIView(width: 2, height: 35, backgroundColor: .appMainColor, cornerRadius: 1)
        parentCommentView.addSubview(indicatorView)
        indicatorView.autoPinTopAndLeadingToSuperView()
        indicatorView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 5)
        
        parentCommentView.addSubview(parentCommentTitleLabel)
        parentCommentTitleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: -2)
        parentCommentTitleLabel.autoPinEdge(.leading, to: .trailing, of: indicatorView, withOffset: 10)
        
        parentCommentView.addSubview(parentCommentLabel)
        parentCommentLabel.autoPinEdge(.top, to: .bottom, of: parentCommentTitleLabel)
        parentCommentLabel.autoPinEdge(.leading, to: .trailing, of: indicatorView, withOffset: 10)
        parentCommentLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        parentCommentView.addSubview(closeParentCommentButton)
        closeParentCommentButton.autoPinEdge(toSuperviewEdge: .trailing)
        closeParentCommentButton.autoPinEdge(.leading, to: .trailing, of: parentCommentLabel)
        closeParentCommentButton.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        closeParentCommentButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        closeParentCommentButton.addTarget(self, action: #selector(closeButtonDidTouch), for: .touchUpInside)
        
        // Avatar
//        addSubview(avatarImageView)
//        avatarImageView.autoPinBottomAndLeadingToSuperView(inset: 10, xInset: 16)
//        avatarImageView.observeCurrentUserAvatar()
//            .disposed(by: disposeBag)
        
        // TextView
        addSubview(textView)
        textView.autoPinEdge(.top, to: .bottom, of: parentCommentView)
        textView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10.0)
        textView.autoPinEdge(toSuperviewEdge: .left, withInset: 15.0)
//        textView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 5)
        
        parentCommentView.autoPinEdge(.leading, to: .leading, of: textView, withOffset: 10)
        parentCommentView.autoPinEdge(.trailing, to: .trailing, of: textView, withOffset: -10)
        
        // Send button
        addSubview(sendButton)
        sendButton.autoPinEdge(.leading, to: .trailing, of: textView, withOffset: 5.0)
        sendButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        sendButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10.0)
//        sendButton.autoPinBottomAndTrailingToSuperView(inset: 10, xInset: 16)
        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        bind()
        
        parentComment = nil
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
    
    func setParentComment() {
        guard let comment = parentComment else {
            parentCommentView.heightConstraint?.constant = 0
            parentCommentView.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
            return
        }
        parentCommentView.heightConstraint?.constant = 40
        parentCommentView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        parentCommentLabel.attributedText = comment.document.toAttributedString(
            currentAttributes: [.font: UIFont.systemFont(ofSize: 13)],
            attachmentType: TextAttachment.self)
    }
    
    @objc func closeButtonDidTouch() {
        mode = .new
        parentComment = nil
    }
    
    #warning("support image posting")
}
