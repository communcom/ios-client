//
//  EditorPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 29/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class EditorPageVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextView: ExpandableTextView!
    @IBOutlet weak var contentView: EditorPageTextView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var adultButton: UIButton!
    @IBOutlet weak var hideKeyboardButton: UIButton!
    @IBOutlet weak var sendPostButton: UIBarButtonItem!
    
    // MARK: - Properties
    var viewModel: EditorPageViewModel?
    let disposeBag = DisposeBag()
    lazy var defaultAttributeForContentTextView: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.systemFont(ofSize: 17)]
    }()
    
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
        
        contentView.textContainerInset = UIEdgeInsets.zero
        contentView.textView.textContainer.lineFragmentPadding = 0
        contentView.textView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        contentView.textView.typingAttributes = defaultAttributeForContentTextView
        // you should ensure layout
        contentView.textView.layoutManager
            .ensureLayout(for: contentView.textView.textContainer)
        
        // if editing post
        if let post = viewModel?.postForEdit {
            showIndetermineHudWithMessage("loading post".localized().uppercaseFirst)
            // Get full post
            NetworkService.shared.getPost(withPermLink: post.contentId.permlink, forUser: post.contentId.userId)
                .subscribe(onSuccess: {post in
                    self.hideHud()
                    self.titleTextView.rx.text.onNext(post.content.title)
                    self.contentView.parseText(post.content.body.full)
                    self.viewModel?.postForEdit = post
                }, onError: {error in
                    self.hideHud()
                    self.showError(error)
                })
                .disposed(by: disposeBag)
        }
        
        // bottom buttons
        hideKeyboardButton.isHidden = true
        
        bindUI()
    }
}
