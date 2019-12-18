//
//  MyProfileEditBioVC.swift
//  Commun
//
//  Created by Chung Tran on 10/31/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class MyProfileEditBioVC: EditorVC {
    // MARK: - Properties
    let bioLimit = 180
    var bio: String?
    let didConfirm = PublishSubject<String>()
    
    // MARK: - Subviews
    lazy var textView: UITextView = {
        let textView = UITextView(forAutoLayout: ())
        textView.typingAttributes = [.font: UIFont.systemFont(ofSize: 17)]
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.placeholder = "enter text".localized().uppercaseFirst + "..."
        textView.keyboardDismissMode = .onDrag
        return textView
    }()
    
    lazy var textViewCharactersCountLabel = UILabel.with(text: "0", textSize: 15, weight: .semibold, textColor: .white)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // header
        headerLabel.text = (bio == nil ? "add bio" : "edit bio").localized().uppercaseFirst
        textView.rx.text.onNext(bio)
        
        // actionButton
        actionButton.setTitle("save".localized().uppercaseFirst, for: .normal)
        actionButton.backgroundColor = .black
        
        // charactersCountLabel
        let charactersCountContainerView = UIView(height: 35, backgroundColor: .black, cornerRadius: 35/2)
        toolbar.addSubview(charactersCountContainerView)
        charactersCountContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        charactersCountContainerView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        
        charactersCountContainerView.addSubview(textViewCharactersCountLabel)
        textViewCharactersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        textViewCharactersCountLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        let limitLabel = UILabel.with(text: "/\(bioLimit)", textSize: 15, weight: .semibold, textColor: #colorLiteral(red: 0.6874092221, green: 0.693797946, blue: 0.7710194588, alpha: 1))
        charactersCountContainerView.addSubview(limitLabel)
        limitLabel.autoPinEdge(.leading, to: .trailing, of: textViewCharactersCountLabel)
        limitLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        limitLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        // hide buttons
        buttonsCollectionView.isHidden = true
    }
    
    override func bind() {
        // Bind textView
        let bioChanged = textView.rx.text.orEmpty
            .map {$0.count != 0 && $0 != self.bio && $0.count <= self.bioLimit}
        
        bioChanged.bind(to: actionButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .map {"\($0.count)"}
            .bind(to: textViewCharactersCountLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func layoutContentView() {
        contentView.addSubview(textView)
        textView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    override func send() {
        if textView.text != bio {
            didConfirm.onNext(textView.text)
        }
        didConfirm.onCompleted()
        back()
    }
    
    override func close() {
        if textView.text.isEmpty {
            super.close()
            return
        }
        
        showAlert(title: "end editing".localized().uppercaseFirst + "?", message: "do you really want to quit without saving".localized().uppercaseFirst + "?", buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
            if index == 0 {
                super.close()
            }
        }
    }
}
