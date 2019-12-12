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
    private let disposeBag = DisposeBag()
    
    private var parentComment: ResponseAPIContentGetComment? {
        didSet {
            setParentComment()
        }
    }
    
    var post: ResponseAPIContentGetPost? {
        didSet {
            viewModel.post = post
        }
    }
    
    private var mode: Mode = .new {
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
    lazy var parentCommentTitleLabel = UILabel.with(textSize: CGFloat.adaptive(width: 15.0), weight: .semibold, textColor: .appMainColor)
    lazy var parentCommentAttachmentView = UIImageView(width: 35, height: 35, cornerRadius: 4)
    lazy var parentCommentLabel = UILabel.with(textSize: CGFloat.adaptive(width: 13.0))
    lazy var closeParentCommentButton = UIButton.circle(size: CGFloat.adaptive(width: 20.0), backgroundColor: .white, imageName: "icon-close-black-default")
        
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
        parentCommentView.autoPinEdge(toSuperviewEdge: .top, withInset: CGFloat.adaptive(height: 11.0))
        
        let indicatorView = UIView(width: CGFloat.adaptive(width: 2.0), height: CGFloat.adaptive(height: 35.0), backgroundColor: .appMainColor, cornerRadius: CGFloat.adaptive(width: 1.0))
        parentCommentView.addSubview(indicatorView)
        indicatorView.autoPinTopAndLeadingToSuperView()
        indicatorView.autoPinEdge(toSuperviewEdge: .bottom, withInset: CGFloat.adaptive(height: 5.0))
        
        parentCommentView.addSubview(parentCommentAttachmentView)
        parentCommentAttachmentView.autoPinEdge(.leading, to: .trailing, of: indicatorView, withOffset: 5)
        parentCommentAttachmentView.autoPinEdge(toSuperviewEdge: .top)
        
        parentCommentView.addSubview(parentCommentTitleLabel)
        parentCommentTitleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: CGFloat.adaptive(height: -2.0))
        parentCommentTitleLabel.autoPinEdge(.leading, to: .trailing, of: parentCommentAttachmentView, withOffset: CGFloat.adaptive(width: 5.0))
        
        parentCommentView.addSubview(parentCommentLabel)
        parentCommentLabel.autoPinEdge(.top, to: .bottom, of: parentCommentTitleLabel)
        parentCommentLabel.autoPinEdge(.leading, to: .leading, of: parentCommentTitleLabel)
        
        parentCommentView.addSubview(closeParentCommentButton)
        closeParentCommentButton.autoPinEdge(toSuperviewEdge: .trailing)
        closeParentCommentButton.autoPinEdge(.leading, to: .trailing, of: parentCommentLabel, withOffset: CGFloat.adaptive(width: 21.0))
        closeParentCommentButton.autoAlignAxis(toSuperviewAxis: .horizontal)
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

        // parentCommentView vs stackview
        parentCommentView.autoPinEdge(.trailing, to: .trailing, of: stackView, withOffset: -6)
        parentCommentView.autoPinEdge(.leading, to: .leading, of: textView)
        
        bind()
        
        parentComment = nil
    }
    
    func setMode(_ mode: Mode, comment: ResponseAPIContentGetComment?) {
        self.mode = mode
        parentComment = comment
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
        
        if let attachment = comment.attachments.first,
            attachment.type == "image"
        {
            parentCommentAttachmentView.widthConstraint?.constant = 35
            parentCommentAttachmentView.setImageDetectGif(with: attachment.content.stringValue)
        }
        else {
            parentCommentAttachmentView.widthConstraint?.constant = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        parentCommentLabel.attributedText = comment.document?.toAttributedString(
            currentAttributes: [.font: UIFont.systemFont(ofSize: 13)],
            attachmentType: TextAttachment.self)
    }
    
    
    // MARK: - Actions
    
    
    #warning("support image posting")
}

extension CommentForm {
    // MARK: - Actions
    @objc func closeButtonDidTouch() {
        setMode(.new, comment: nil)
    }
    
    @objc func commentAddImage() {
        Logger.log(message: "Add image to comment...", event: .debug)
    }
    
    @objc func commentSend() {
        if mode != .new && parentComment == nil { return}
        
        #warning("send image")
        var block: ResponseAPIContentBlock!
        textView.getContentBlock()
            .observeOn(MainScheduler.instance)
            .flatMap { parsedBlock -> Single<SendPostCompletion> in
                //clean
                block = parsedBlock
                block.maxId = nil
                
                // send new comment
                let request: Single<SendPostCompletion>
                switch self.mode {
                case .new:
                    request = self.viewModel.sendNewComment(block: block)
                case .edit:
                    request = self.viewModel.updateComment(self.parentComment!, block: block)
                case .reply:
                    request = self.viewModel.replyToComment(self.parentComment!, block: block)
                }
                
                self.textView.text = ""
                self.mode = .new
                self.parentComment = nil
                self.endEditing(true)
                
                return request
            }
            .subscribe(onError: { [weak self] error in
//                self.setLoading(false)
                self?.parentViewController?.showError(error)
            })
            .disposed(by: disposeBag)
    }
}

