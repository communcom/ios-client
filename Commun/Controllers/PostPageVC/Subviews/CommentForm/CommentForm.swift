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
    lazy var closeParentCommentButton = UIButton.close()
        
    lazy var textView: CommentTextView = {
        let textView = CommentTextView(forExpandable: ())
        textView.placeholder = "write a comment".localized().uppercaseFirst + "..."
        textView.backgroundColor = .f3f5fa
        textView.cornerRadius = 35 / 2

        return textView
    }()

    lazy var imageButton = CommunButton.circle(size:                 CGFloat.adaptive(width: 35.0),
                                               backgroundColor:      .white,
                                               tintColor:            UIColor(hexString: "#A5A7BD"),
                                               imageName:            "icon-send-comment-gray-default",
                                               imageEdgeInsets:      .zero)

    lazy var sendButton = CommunButton.circle(size:                 CGFloat.adaptive(width: 35.0),
                                              backgroundColor:      UIColor(hexString: "#6A80F5")!,
                                              tintColor:            .white,
                                              imageName:            "send",
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
        
        let stackView = UIStackView(axis: .horizontal, spacing: CGFloat.adaptive(width: 5.0))
        addSubview(stackView)
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.autoPinEdge(.top, to: .bottom, of: parentCommentView)
        stackView.autoPinBottomAndLeadingToSuperView(inset: CGFloat.adaptive(height: 10.0), xInset: CGFloat.adaptive(width: 10.0))
        stackView.autoPinEdge(toSuperviewEdge: .right, withInset: CGFloat.adaptive(width: 10.0))
        
        // Add subviews
        stackView.addArrangedSubview(imageButton)
        imageButton.addTarget(self, action: #selector(commentAddImage), for: .touchUpInside)
        
        stackView.addArrangedSubview(textView)

        stackView.addArrangedSubview(sendButton)
        sendButton.addTarget(self, action: #selector(commentSend), for: .touchUpInside)
        sendButton.isHidden = true

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
                self.sendButton.isEnabled = !isEmpty
                self.sendButton.isHidden = isEmpty
                
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
        parentCommentLabel.attributedText = comment.document?.toAttributedString(
            currentAttributes: [.font: UIFont.systemFont(ofSize: 13)],
            attachmentType: TextAttachment.self)
    }
    
    
    // MARK: - Actions
    @objc func closeButtonDidTouch() {
        mode = .new
        parentComment = nil
    }
    
    #warning("support image posting")
}
