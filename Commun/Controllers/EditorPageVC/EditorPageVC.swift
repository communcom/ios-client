//
//  EditorPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 29/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift

class EditorPageVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextView: ExpandableTextView!
    @IBOutlet weak var contentTextView: EditorPageTextView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var adultButton: StateButton!
    @IBOutlet weak var photoPickerButton: StateButton!
    @IBOutlet weak var boldButton: StateButton!
    @IBOutlet weak var italicButton: StateButton!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var addLinkButton: StateButton!
    @IBOutlet weak var clearFormattingButton: UIButton!
    @IBOutlet weak var hideKeyboardButton: UIButton!
    @IBOutlet weak var sendPostButton: UIBarButtonItem!
    
    @IBOutlet weak var editorToolsToContainerTrailingSpace: NSLayoutConstraint!
    
    // MARK: - Properties
    var viewModel: EditorPageViewModel?
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel == nil {
            viewModel = EditorPageViewModel()
        }
        
        self.title = (viewModel?.postForEdit != nil ? "edit post" : "create post").localized().uppercaseFirst
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        dropDownView.layer.borderWidth = 1.0
        dropDownView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.placeholder = "title placeholder".localized().uppercaseFirst
        
        contentTextView.textContainerInset = UIEdgeInsets.zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        // you should ensure layout
        contentTextView.layoutManager
            .ensureLayout(for: contentTextView.textContainer)
        
        // if editing post
        if let post = viewModel?.postForEdit {
            showIndetermineHudWithMessage("loading post".localized().uppercaseFirst)
            // Get full post
            NetworkService.shared.getPost(withPermLink: post.contentId.permlink, forUser: post.contentId.userId)
                .do(onSuccess: { (post) in
                    if post.content.body.full == nil {
                        throw ErrorAPI.responseUnsuccessful(message: "Content not found")
                    }
                })
                .subscribe(onSuccess: {post in
                    self.hideHud()
                    self.titleTextView.rx.text.onNext(post.content.title)
                    self.contentTextView.parseText(post.content.body.full!)
                    self.viewModel?.postForEdit = post
                }, onError: {error in
                    self.hideHud()
                    self.showError(error)
                    self.closeButtonDidTouch(self)
                })
                .disposed(by: disposeBag)
        }
        
        // bottom buttons
        photoPickerButton.isSelected = true
        
        boldButton.isHidden = true
        italicButton.isHidden = true
        colorPickerButton.isHidden = true
        addLinkButton.isHidden = true
        hideKeyboardButton.isHidden = true
        clearFormattingButton.isHidden = true
        
        bindUI()
    }
}
