//
//  CommonEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class CommonEditorVC: UIViewController {
    // MARK: - Properties
    let contentLettersLimit = 30000
    let disposeBag = DisposeBag()
    var viewModel: EditorViewModel?
    var contentCombined: Observable<[Any]>! {
        return nil
    }
    var contentTextView: ContentTextView {
        fatalError("Must override")
    }
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var adultButton: StateButton!
    @IBOutlet weak var photoPickerButton: StateButton!
    @IBOutlet weak var boldButton: StateButton!
    @IBOutlet weak var italicButton: StateButton!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var addLinkButton: StateButton!
    @IBOutlet weak var clearFormattingButton: UIButton!
    @IBOutlet weak var hideKeyboardButton: UIButton!
    @IBOutlet weak var sendPostButton: StepButton!
    @IBOutlet weak var editorToolsToContainerLeadingSpace: NSLayoutConstraint!

    @IBOutlet weak var contentTextViewCharacterCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViewModel()
        
        setUpViews()
        
        bindUI()
    }
    
    func createViewModel() {
        if viewModel == nil {
            viewModel = EditorViewModel()
        }
    }
    
    func setUpViews() {
//        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        // you should ensure layout
        contentTextView.layoutManager
            .ensureLayout(for: contentTextView.textContainer)
        
        dropDownView.layer.borderWidth = 1.0
        dropDownView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        
        // bottom buttons
        photoPickerButton.isSelected = true
        
        boldButton.isHidden = true
        italicButton.isHidden = true
        colorPickerButton.isHidden = true
        addLinkButton.isHidden = true
        hideKeyboardButton.isHidden = true
        clearFormattingButton.isHidden = true
        contentTextViewCharacterCountLabel.isHidden = true
    }
    
    
    func bindUI() {
        // isAdult
        bindIsAdultButton()
        
        // keyboard
        bindKeyboardHeight()
        
        // postButton
        bindSendPostButton()
    }
    
    func bindIsAdultButton() {
        guard let viewModel = viewModel else {return}
        adultButton.rx.tap
            .map {_ in !viewModel.isAdult.value}
            .bind(to: viewModel.isAdult)
            .disposed(by: disposeBag)
        
        viewModel.isAdult
            .bind(to: self.adultButton.rx.isSelected)
            .disposed(by: disposeBag)
    }
    
    func bindKeyboardHeight() {
        UIResponder.keyboardHeightObservable
            .map {$0 == 0 ? true: false}
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { (isHidden) in
                self.hideKeyboardButton.isHidden = isHidden
                self.editorToolsToContainerLeadingSpace.constant = isHidden ? 0 : 54
            })
            .disposed(by: disposeBag)
    }

    func bindSendPostButton() {
        // Verification
        #warning("Verify community")
        contentCombined
            .map {_ in self.verify()}
            .bind(to: sendPostButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func verify() -> Bool {
        fatalError("must override")
    }
    
    // MARK: - Actions
    @IBAction func hideKeyboardButtonDidTouch(_ sender: Any) {
        view.endEditing(true)
    }
}
