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
    // MARK: - Nested types
    enum Mode {
        case new
        case edit
        case reply
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    lazy var viewModel = CommentFormViewModel()
    var post: ResponseAPIContentGetPost? {
        didSet {
            viewModel.post = post
        }
    }
    
    var originParentComment: ResponseAPIContentGetComment?
    private var parentComment: ResponseAPIContentGetComment?
    private var mode: Mode = .new
    var localImage: UIImage? {
        didSet {
            setUp()
        }
    }
    
    // MARK: - Subviews
    var constraintTop: NSLayoutConstraint?
    lazy var stackView = UIStackView(axis: .horizontal, spacing: CGFloat.adaptive(width: 5.0))
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
        
        // bottom stackView
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        
        addSubview(stackView)
        stackView.autoPinBottomAndLeadingToSuperView(inset: CGFloat.adaptive(height: 10.0), xInset: CGFloat.adaptive(width: 10.0))
        stackView.autoPinEdge(toSuperviewEdge: .right, withInset: CGFloat.adaptive(width: 10.0))
        
        // Add subviews
        stackView.addArrangedSubview(imageButton)
        imageButton.addTarget(self, action: #selector(commentAddImage), for: .touchUpInside)
        
        stackView.addArrangedSubview(textView)

        stackView.addArrangedSubview(sendButton)
        sendButton.addTarget(self, action: #selector(commentSend), for: .touchUpInside)
        sendButton.isHidden = true
        
        setUp()
        bind()
    }
    
    func setMode(_ mode: Mode, comment: ResponseAPIContentGetComment?) {
        self.mode = mode
        originParentComment = comment
        parentComment = comment
        setUp()
    }
    
    func setUp() {
        // clear
        constraintTop?.isActive = false
        for subview in subviews {
            if subview != stackView {
                subview.removeFromSuperview()
            }
        }
        
        // mode
        
        var imageView: UIImageView?
        if let image = localImage {
            imageView = UIImageView(width: CGFloat.adaptive(height: 80), height: CGFloat.adaptive(height: 80), cornerRadius: CGFloat.adaptive(height: 15))
            imageView!.image = image
            addSubview(imageView!)
            constraintTop = imageView!.autoPinEdge(toSuperviewEdge: .top, withInset: CGFloat.adaptive(height: 10.0))
            imageView!.autoPinEdge(toSuperviewEdge: .leading, withInset: CGFloat.adaptive(height: 10.0))
            imageView!.autoPinEdge(.bottom, to: .top, of: stackView, withOffset: CGFloat.adaptive(height: -10.0))
            
            UIView.animate(withDuration: 0.3) {
                imageView!.layoutIfNeeded()
            }
        }
        
        
        if mode == .new {
            if imageView == nil {
                constraintTop = stackView.autoPinEdge(toSuperviewEdge: .top, withInset: CGFloat.adaptive(height: 10.0))
            }
        }
        else {
            let parentCommentView = createParentCommentView()
            addSubview(parentCommentView)
            
            if imageView == nil {
                constraintTop = parentCommentView.autoPinEdge(toSuperviewEdge: .top, withInset: CGFloat.adaptive(height: 10.0))
                parentCommentView.autoPinEdge(.leading, to: .leading, of: textView)
            }
            else {
                parentCommentView.autoPinEdge(.leading, to: .trailing, of: imageView!, withOffset: CGFloat.adaptive(height: 16))
            }
            
            parentCommentView.autoPinEdge(.trailing, to: .trailing, of: stackView, withOffset: -6)
            parentCommentView.autoPinEdge(.bottom, to: .top, of: stackView, withOffset: -10)
            UIView.animate(withDuration: 0.3, animations: {
                parentCommentView.layoutIfNeeded()
            })
        }
    }
    
    func createParentCommentView() -> UIView {
        let height: CGFloat = 35
        
        let view = UIView(height: height)
        
        let indicatorView = UIView(width: 2, height: height, backgroundColor: .appMainColor, cornerRadius: 1)
        view.addSubview(indicatorView)
        indicatorView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let imageView = UIImageView(width: height, height: height, cornerRadius: 4)
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        imageView.autoPinEdge(.leading, to: .trailing, of: indicatorView, withOffset: 5)
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        if let url = parentComment?.attachments.first?.thumbnailUrl
        {
            imageView.widthConstraint?.constant = height
            imageView.setImageDetectGif(with: url)
        }
        else {
            imageView.widthConstraint?.constant = 0
        }
        
        let stackView = UIStackView(axis: .vertical)
        stackView.alignment = .leading
        view.addSubview(stackView)
        stackView.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 5)
        stackView.autoPinEdge(toSuperviewEdge: .top)
        stackView.autoPinEdge(toSuperviewEdge: .bottom)
        
        let parentCommentTitleLabel = UILabel.with(textSize: CGFloat.adaptive(width: 15.0), weight: .semibold, textColor: .appMainColor)
        
        if mode == .edit {
            parentCommentTitleLabel.text = "edit comment".localized().uppercaseFirst
        }
        
        if mode == .reply {
            parentCommentTitleLabel.text = "reply to comment".localized().uppercaseFirst
        }
        
        let parentCommentLabel = UILabel.with(textSize: CGFloat.adaptive(width: 13.0))
        
        
        parentCommentLabel.attributedText = parentComment?.document?.toAttributedString(
            currentAttributes: [.font: UIFont.systemFont(ofSize: 13)],
            attachmentType: TextAttachment.self)
        
        stackView.addArrangedSubviews([parentCommentTitleLabel, parentCommentLabel])
        
        let closeParentCommentButton = UIButton.circle(size: CGFloat.adaptive(width: 20.0), backgroundColor: .white, imageName: "icon-close-black-default")
        closeParentCommentButton.addTarget(self, action: #selector(closeButtonDidTouch), for: .touchUpInside)
        
        view.addSubview(closeParentCommentButton)
        closeParentCommentButton.autoPinEdge(toSuperviewEdge: .trailing)
        closeParentCommentButton.autoPinEdge(.leading, to: .trailing, of: stackView, withOffset: CGFloat.adaptive(width: 21.0))
        closeParentCommentButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        return view
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
    
    #warning("support image posting")
}

extension CommentForm {
    // MARK: - Actions
    @objc func closeButtonDidTouch() {
        setMode(.new, comment: nil)
    }
    
    @objc func commentAddImage() {
        let pickerVC = CustomTLPhotosPickerVC.singleImage
        self.parentViewController?.present(pickerVC, animated: true, completion: nil)
        
        pickerVC.rx.didSelectAnImage
            .subscribe(onNext: {[weak self] image in
                self?.localImage = image
                pickerVC.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
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

