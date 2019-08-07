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
    // MARK: - Properties
    var parentAuthor: String?
    var parentPermlink: String?
    
    private let bag = DisposeBag()
    let commentDidSend = PublishSubject<(Void)>()
    let commentDidFailedToSend = PublishSubject<Error>()
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textView: ExpandableTextView!
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
        
        // observe image
        imageView.rx.isEmpty
            .map {$0 ? 0: 85}
            .bind(to: imageWrapperHeightConstraint.rx.constant)
            .disposed(by: bag)
    }
    
    // MARK: - Actions
    @IBAction func removeImageDidTouch(_ sender: Any) {
        imageView.image = nil
    }
    
    @IBAction func addImageDidTouch(_ sender: Any) {
        let pickerVC = CustomTLPhotosPickerVC.singleImage
        self.parentViewController?.present(pickerVC, animated: true, completion: nil)
        
        pickerVC.rx.didSelectAssets
            .filter {($0.count > 0) && ($0.first?.fullResolutionImage != nil)}
            .map {$0.first!.fullResolutionImage!}
            .subscribe(onNext: {image in
                self.imageView.image = image
                pickerVC.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
    
    @IBAction func btnSendDidTouch(_ sender: Any) {
        if let image = imageView.image {
            NetworkService.shared.uploadImage(image)
                .do(onSubscribe: { [weak self] in
                    self?.sendButton.isEnabled = false
                })
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] url in
                    guard let strongSelf = self else {return}
                    
                    strongSelf.sendComment(text: strongSelf.textView.text, metaData: strongSelf.prepareEmbeds(imageURL: url) ?? "", tags: strongSelf.textView.text.getTags())
                    
                }, onError: {[weak self] error in
                    self?.sendButton.isEnabled = true
                    self?.parentViewController?.showError(error)
                })
                .disposed(by: bag)
        } else {
            sendComment(text: textView.text, metaData: prepareEmbeds() ?? "", tags: textView.text.getTags())
        }
    }
    
    func sendComment(text: String, metaData: String, tags: [String]) {
        NetworkService.shared.sendComment(
            withMessage:       text,
            parentAuthor:      parentAuthor ?? "",
            parentPermlink:    parentPermlink ?? "",
            metaData:          metaData,
            tags:              tags)
            .do(onSubscribe: { [weak self] in
                self?.sendButton.isEnabled = false
            })
            .observeOn(MainScheduler.instance)
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
    
    func prepareEmbeds(imageURL: String? = nil) -> String? {
        var embeds = [[String: Any]]()
        if let url = imageURL {
            // Add photo
            embeds.append([
                "type": "photo",
                "url": url,
                "id": Int(Date().timeIntervalSince1970)
                ])
        }
        
        for word in textView.text.components(separatedBy: " ") {
            if word.contains("http://") || word.contains("https://") {
                embeds.append(["url": word])
            }
        }
        
        // Prepare embeded
        let json = ["embeds": embeds]
        
        return json.jsonString()
    }
    
}
