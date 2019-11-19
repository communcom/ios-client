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
        textView.placeholder = "add a comment".localized().uppercaseFirst + "..."
        textView.backgroundColor = .f3f5fa
        textView.cornerRadius = 35 / 2
        return textView
    }()
    lazy var sendButton = CommunButton.circle(size: 35, backgroundColor: .appMainColor, tintColor: .white, imageName: "send", imageEdgeInsets: UIEdgeInsets(inset: 10))
    
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
        addSubview(avatarImageView)
        avatarImageView.autoPinBottomAndLeadingToSuperView(inset: 10, xInset: 16)
        avatarImageView.observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        
        // TextView
        addSubview(textView)
        textView.autoPinEdge(.top, to: .bottom, of: parentCommentView)
        textView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        textView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 5)
        
        parentCommentView.autoPinEdge(.leading, to: .leading, of: textView, withOffset: 10)
        parentCommentView.autoPinEdge(.trailing, to: .trailing, of: textView, withOffset: -10)
        
        // Send button
        addSubview(sendButton)
        sendButton.autoPinEdge(.leading, to: .trailing, of: textView, withOffset: 5)
        sendButton.autoPinBottomAndTrailingToSuperView(inset: 10, xInset: 16)
        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        bind()
        
        parentComment = nil
    }

    @objc func sendComment() {
        if mode != .new && parentComment == nil { return}
        
        #warning("send image")
        textView.getContentBlock()
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: {
                self.textView.isUserInteractionEnabled = false
                self.parentViewController?.showIndetermineHudWithMessage(
                    "parsing content".localized().uppercaseFirst)
            })
            .flatMapCompletable { block in
                //clean
                var block = block
                block.maxId = nil
                
                // send new comment
                let request: Completable
                switch self.mode {
                case .new:
                    request = self.viewModel.sendNewComment(block: block)
                case .edit:
                    request = self.viewModel.updateComment(self.parentComment!, block: block)
                case .reply:
                    request = self.viewModel.replyToComment(self.parentComment!, block: block)
                }
                
                return request
                    .do(onSubscribe: {
                        self.parentViewController?.showIndetermineHudWithMessage(
                            "sending comment".localized().uppercaseFirst)
                    })
            }
            .subscribe(onCompleted: {
                self.parentViewController?.hideHud()
                self.textView.isUserInteractionEnabled = true
                
                self.mode = .new
                self.parentComment = nil
                
                #warning("reload comments")
            }) { (error) in
                self.parentViewController?.hideHud()
                self.parentViewController?.showError(error)
                self.textView.isUserInteractionEnabled = true
            }
            .disposed(by: disposeBag)
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
