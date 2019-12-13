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
import RxCocoa

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
    
    private var parentComment: ResponseAPIContentGetComment? {
        didSet {
            self.url = parentComment?.attachments.first?.thumbnailUrl
        }
    }
    private var mode: Mode = .new
    let localImage = BehaviorRelay<UIImage?>(value: nil)
    var url: String?
    
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
        parentComment = comment
        
        textView.text = nil
        
        if mode == .edit {
            let aStr = parentComment?.document?.toAttributedString(
                currentAttributes: [.font: UIFont.systemFont(ofSize: 13)],
                attachmentType: TextAttachment.self)
            textView.attributedText = aStr
            textView.originalAttributedString = aStr
        }
        
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
        if (localImage.value != nil) || (mode == .edit && url != nil)
        {
            imageView = MyImageView(width: CGFloat.adaptive(height: 80), height: CGFloat.adaptive(height: 80), cornerRadius: CGFloat.adaptive(height: 15))
            addSubview(imageView!)
            constraintTop = imageView!.autoPinEdge(toSuperviewEdge: .top, withInset: CGFloat.adaptive(height: 10.0))
            imageView!.autoPinEdge(toSuperviewEdge: .leading, withInset: CGFloat.adaptive(height: 10.0))
            imageView!.autoPinEdge(.bottom, to: .top, of: stackView, withOffset: CGFloat.adaptive(height: -10.0))
            
            let closeButton = UIButton.close(size: 24)
            closeButton.borderColor = .white
            closeButton.borderWidth = 2
            addSubview(closeButton)
            closeButton.autoPinEdge(.top, to: .top, of: imageView!, withOffset: -6)
            closeButton.autoPinEdge(.trailing, to: .trailing, of: imageView!, withOffset: 6)
            closeButton.addTarget(self, action: #selector(closeImageDidTouch), for: .touchUpInside)
            
            if let image = localImage.value {
                imageView?.image = image
            }
            else if let url = url {
                imageView?.setImageDetectGif(with: url)
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
        
        if let url = parentComment?.attachments.first?.thumbnailUrl,
            mode != .edit
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
        // local image
        localImage
            .subscribe(onNext: { (_) in
                self.setUp()
            })
            .disposed(by: disposeBag)
        
        
        // setup observer
        let textViewChanged = textView.rx.text.orEmpty
            .distinctUntilChanged()
            .map {_ in ()}
        
        let imageChanged = localImage.map {_ in ()}
        
        Observable.merge(textViewChanged, imageChanged)
            .map {_ -> Bool in
                if self.localImage.value != nil {return true}
                
                let isTextViewEmpty = self.textView.text.isEmpty
                let isTextChanged = (self.textView.attributedText != self.textView.originalAttributedString)
                
                if self.mode == .edit && !isTextViewEmpty && self.url != self.parentComment?.attachments.first?.thumbnailUrl
                {
                    return true
                }
                
                return !isTextViewEmpty && isTextChanged
            }
            .subscribe(onNext: { (shouldEnableSendButton) in
                self.sendButton.isEnabled = shouldEnableSendButton
                self.sendButton.isHidden = !shouldEnableSendButton
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }
}

extension CommentForm {
    // MARK: - Actions
    @objc func closeButtonDidTouch() {
        setMode(.new, comment: nil)
    }
    
    @objc func closeImageDidTouch() {
        self.url = nil
        localImage.accept(nil)
    }
    
    @objc func commentAddImage() {
        let pickerVC = CustomTLPhotosPickerVC.singleImage
        self.parentViewController?.present(pickerVC, animated: true, completion: nil)
        
        pickerVC.rx.didSelectAnImage
            .subscribe(onNext: {[weak self] image in
                self?.localImage.accept(image)
                pickerVC.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func commentSend() {
        if mode != .new && parentComment == nil { return}
        
        textView.getContentBlock()
            .observeOn(MainScheduler.instance)
            .map { parsedBlock -> ResponseAPIContentBlock in
                if let url = self.url {
                    var block = parsedBlock
                    
                    var array = parsedBlock.content.arrayValue ?? []
                    
                    array.append(
                        ResponseAPIContentBlock(id: (parsedBlock.maxId ?? 0) + 1, type: "attachments", attributes: nil, content: .array([
                            ResponseAPIContentBlock(id: (parsedBlock.maxId ?? 0) + 2, type: "image", attributes: nil, content: .string(url))
                        ]))
                    )
                    
                    block.content = .array(array)
                    return block
                }
                
                return parsedBlock
            }
            .flatMap { parsedBlock -> Single<SendPostCompletion> in
                //clean
                var block = parsedBlock
                block.maxId = nil
                
                // send new comment
                let request: Single<SendPostCompletion>
                switch self.mode {
                case .new:
                    request = self.viewModel.sendNewComment(block: block, uploadingImage: self.localImage.value)
                case .edit:
                    request = self.viewModel.updateComment(self.parentComment!, block: block, uploadingImage: self.localImage.value)
                case .reply:
                    request = self.viewModel.replyToComment(self.parentComment!, block: block, uploadingImage: self.localImage.value)
                }
                
                self.textView.text = ""
                self.mode = .new
                self.parentComment = nil
                self.localImage.accept(nil)
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

