//
//  PostEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PostEditorVC: EditorVC {
    // MARK: - Constants
    let communityDraftKey = "PostEditorVC.communityDraftKey"
    
    // MARK: - Properties
    
    // MARK: - Computed properties
    var contentLettersLimit: UInt {30000}
    
    /// Condition that define when to start updating send button state
    var contentCombined: Observable<Void> {
        viewModel.community.map {_ in ()}
    }
    
    /// Define whenever content is valid to enable send button
    var isContentValid: Bool {
        viewModel.community.value != nil
    }
    
    var viewModel: PostEditorViewModel {
        fatalError("Must override")
    }
    
    var postTitle: String? {
        fatalError("Must override")
    }
    
    var chooseCommunityAfterLoading = true
    
    // MARK: - Subviews
    // community
    lazy var communityView = UIView(forAutoLayout: ())
    lazy var communityAvatarImage = MyAvatarImageView(size: 40)
    lazy var communityNameLabel = UILabel.with(text: "choose a community".localized().uppercaseFirst, textSize: 15, weight: .semibold, numberOfLines: 0)
    lazy var contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    
    var contentTextView: ContentTextView {
        fatalError("Must override")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // if editing post
        if let post = viewModel.postForEdit {
            communityView.removeGestureRecognizers()
            showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            setUp(with: post)
                .subscribe(onCompleted: {
                    self.hideHud()
                }) { (error) in
                    self.hideHud()
                    self.showError(error)
                }
                .disposed(by: disposeBag)
        } else {
            // parse draft
            if hasDraft {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // your code here
                    self.retrieveDraft()
                }
            } else {
                if chooseCommunityAfterLoading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.chooseCommunityDidTouch()
                    }
                }
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        
        actionButton.setTitle("send post".localized().uppercaseFirst, for: .normal)
        actionButton.backgroundColor = .appMainColor
        
        // common contentTextView
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        headerLabel.text = (viewModel.postForEdit != nil ? "edit post" : "create post").localized().uppercaseFirst
        
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 100, right: 16)
        
        contentTextView.addLinkDidTouch = {[weak self] in
            self?.addLink()
        }

        // add default tool
//        appendTool(EditorToolbarItem.ageLimit)
        appendTool(EditorToolbarItem.addPhoto)
    }
    
    override func bind() {
        super.bind()
        bindKeyboardHeight()
        
        bindSendPostButton()
        
        bindContentTextView()
        
        bindCommunity()
    }
    
    override func didSelectTool(_ item: EditorToolbarItem) {
        super.didSelectTool(item)
        
        guard item.isEnabled else {return}
        
        if item == .setBold {
            contentTextView.toggleBold()
        }
        
        if item == .setItalic {
            contentTextView.toggleItalic()
        }
        
        if item == .clearFormatting {
            contentTextView.clearFormatting()
        }
        
        if item == .addArticle {
            addArticle()
        }
        
        if item == .addPhoto {
            addImage()
        }
        
        if item == .addLink {
            addLink()
        }
        
        if item == .ageLimit {
            addAgeLimit()
        }
    }
    
    // MARK: - action for overriding
    func setUp(with post: ResponseAPIContentGetPost) -> Completable {
        guard let document = post.document,
            let community = post.community
        else {return .empty()}
        viewModel.community.accept(community)
        return contentTextView.parseContentBlock(document)
    }
    
    func getContentBlock() -> Single<ResponseAPIContentBlock> {
        contentTextView.getContentBlock()
    }
}
