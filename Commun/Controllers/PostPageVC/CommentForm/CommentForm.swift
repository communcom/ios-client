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
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var imageWrapperHeightConstraint: NSLayoutConstraint!
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
        
        // observe image
        imageView.rx.isEmpty
            .map {$0 ? 0: 85}
            .bind(to: imageWrapperHeightConstraint.rx.constant)
            .disposed(by: bag)
    }
    
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
}
