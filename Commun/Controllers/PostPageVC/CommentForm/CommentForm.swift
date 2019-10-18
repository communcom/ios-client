//
//  CommentForm.swift
//  Commun
//
//  Created by Chung Tran on 16/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentForm: UIView {
    // MARK: - Properties
    var parentAuthor: String?
    var parentPermlink: String?
    
    private let bag = DisposeBag()
    let commentDidSend = PublishSubject<(Void)>()
    let commentDidFailedToSend = PublishSubject<Error>()
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textView: CommentTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageWrapperHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldToSendBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtnWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Methods
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
            .distinctUntilChanged()
        
        Observable.combineLatest(isTextViewEmpty, imageView.rx.isEmpty)
            .map {$0 && $1}
            .distinctUntilChanged()
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
        
        // observe image
        imageView.rx.isEmpty
            .map {$0 ? 0: 85}
            .bind(to: imageWrapperHeightConstraint.rx.constant)
            .disposed(by: bag)
        
        // forward delegate
        textView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    // MARK: - Actions
    @IBAction func removeImageDidTouch(_ sender: Any) {
        imageView.image = nil
    }
    
    @IBAction func addImageDidTouch(_ sender: Any) {
        let pickerVC = CustomTLPhotosPickerVC.singleImage
        self.parentViewController?.present(pickerVC, animated: true, completion: nil)
        
        pickerVC.rx.didSelectAnImage
            .subscribe(onNext: {image in
                self.imageView.image = image
                pickerVC.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
    
    @IBAction func btnSendDidTouch(_ sender: Any) {
        var block: ResponseAPIContentBlock?
        var id: UInt64!
        
        textView.getContentBlock()
            .flatMap {contentBlock -> Single<ResponseAPIContentBlock?> in
                block = contentBlock
                // transform attachments to contentBlock
                id = (contentBlock.maxId ?? 100) + 1
                var childId = id!
                
                if let image = self.imageView.image {
                    childId += 1
                    return NetworkService.shared.uploadImage(image)
                        .map {ResponseAPIContentBlock(
                                id: childId,
                                type: "image",
                                attributes: nil,
                                content: ResponseAPIContentBlockContent.string($0))}
                }
                else {
                    return .just(nil)
                }
            }
            .do(onSubscribe: { [weak self] in
                self?.sendButton.isEnabled = false
            })
            .map {contentBlock -> ResponseAPIContentBlock in
                guard var childs = block?.content.arrayValue,
                    contentBlock != nil
                else {return block!}
                
                childs.append(ResponseAPIContentBlock(id: id, type: "attachments", attributes: nil, content: .array([contentBlock!])))
                block!.content = .array(childs)
                
                return block!
            }
            .flatMapCompletable { [weak self] contentBlock in
                guard let strongSelf = self else {return .empty()}
                var block = contentBlock
                block.maxId = nil
                let string = try block.jsonString()
                #warning("fix commun code")
                return NetworkService.shared.sendComment(
                    communCode: "cats",
                    parentAuthor: strongSelf.parentAuthor ?? "",
                    parentPermlink: strongSelf.parentPermlink ?? "",
                    message: string,
                    tags: strongSelf.textView.text.getTags())
                .observeOn(MainScheduler.instance)
            }
            .subscribe(onCompleted: { [weak self] in
                self?.textView.text = ""
                self?.imageView.image = nil
                
                self?.sendButton.isEnabled = true
                
                self?.commentDidSend.onNext(())
            }, onError: {[weak self] error in
                self?.sendButton.isEnabled = true
                self?.commentDidFailedToSend.onNext(error)
            })
            .disposed(by: bag)
    }
    
}
