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
    
    var bio: String?
    let didConfirm = PublishSubject<String>()
    private let bag = DisposeBag()
    private let charactersLimit = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set views
        title = (bio == nil ? "add bio" : "edit bio").localized().uppercaseFirst
        textView.rx.text.onNext(bio)

        // bind ui
        bindUI()
    }
    
    func bindUI() {
        // Bind textView
        let bioChanged = textView.rx.text.orEmpty
            .map {$0.count != 0 && $0 != self.bio}
        
        bioChanged.bind(to: postButton.rx.isEnabled)
            .disposed(by: bag)
        
        textView.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.characterCountLabel.text = "\(text.count)/100"
            })
            .disposed(by: bag)
        
        textView.rx.text.orEmpty
            .filter {$0.count > self.charactersLimit}
            .subscribe(onNext: limitCharacters())
            .disposed(by: bag)
    }
    
    func limitCharacters() -> (_ newText: String) -> Void {
        return { newText in
            self.textView.text = String(newText.prefix(self.charactersLimit))
        }
    }
    
    @IBAction func postButtonDidTouch(_ sender: Any) {
        if textView.text != bio {
            didConfirm.onNext(textView.text)
        }
        didConfirm.onCompleted()
        if (isModal) {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController()
        }
    }
    
    @IBAction func cancelButtonDidTouch(_ sender: Any) {
        didConfirm.onCompleted()
        if (isModal) {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController()
        }
    }
}
