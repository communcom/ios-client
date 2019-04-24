//
//  ProfileEditBioVC.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class ProfileEditBioVC: UIViewController {

    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceholder: UILabel!
    
    var bio: String?
    let didConfirm = PublishSubject<String?>()
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set views
        title = (bio == nil) ? "Add".localized() + "bio".localized() : "Edit".localized() + "bio".localized()
        textView.rx.text.onNext(bio)

        // bind ui
        bindUI()
    }
    
    func bindUI() {
        // Bind textView
        let emptyState = textView.rx.text
            .map {$0?.count != 0}
        
        emptyState.bind(to: postButton.rx.isEnabled)
            .disposed(by: bag)
        
        emptyState.bind(to: textViewPlaceholder.rx.isHidden)
            .disposed(by: bag)
        
        textView.rx.text
            .subscribe(onNext: {text in
                self.characterCountLabel.text = "\(text?.count ?? 0)/100"
            })
            .disposed(by: bag)
    
        #warning("limit characters in textView")
    }
    
    @IBAction func postButtonDidTouch(_ sender: Any) {
        if textView.text != bio {
            didConfirm.onNext(textView.text)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonDidTouch(_ sender: Any) {
        didConfirm.onNext(nil)
        dismiss(animated: true, completion: nil)
    }
}
