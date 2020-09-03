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
import PureLayout

class PostEditorVC: EditorVC {
    // MARK: - Constants
    let communityDraftKey = "PostEditorVC.communityDraftKey"
    let titleDraft = "EditorPageVC.titleDraft"
    let titleMinLettersLimit = 2
    let titleBytesLimit = 240
    
    // MARK: - Properties
    var chooseCommunityAfterLoading: Bool
    var parseDraftAfterLoading: Bool
    var explanationViewShowed = false
    
    // MARK: - Computed properties
    var contentLettersLimit: UInt {30000}
    
    /// Condition that define when to start updating send button state
    var contentCombined: Observable<Void> {
        Observable.merge(
            viewModel.community.map {_ in ()},
            titleTextView.rx.text.orEmpty.map {_ in ()},
            contentTextView.rx.text.orEmpty.map {_ in ()}
        )
    }
    
    /// Define whenever content is valid to enable send button
    var hintType: CMHint.HintType?
    var canSendPost: Bool {
        hintType = nil
        let communityChosen = viewModel.community.value != nil
        if !communityChosen {hintType = .chooseCommunity}
        
        // reassign result
        return communityChosen && isContentValid
    }
    
    var isContentValid: Bool {
        let title = titleTextView.text.trimmed
        let content = contentTextView.text.trimmed
        
        // both title and content are not empty
        let titleAndContentAreNotEmpty = !title.isEmpty && !content.isEmpty
        if !titleAndContentAreNotEmpty && hintType == nil {hintType = .error("title and content must not be empty".localized().uppercaseFirst)}
        
        // title is not beyond limit
        let titleIsInsideLimit =
            (title.count >= self.titleMinLettersLimit) &&
                (title.utf8.count <= self.titleBytesLimit)
        if !titleIsInsideLimit && hintType == nil {hintType = .error("title must less than \(titleMinLettersLimit) characters".localized().uppercaseFirst)}
        
        // content inside limit
        let contentInsideLimit = (content.count <= contentLettersLimit)

        if !contentInsideLimit && hintType == nil {
            hintType = .error(String(format: "%@ %i %@", "content must less than".localized().uppercaseFirst, contentLettersLimit, "characters".localized()))
        }
        
        // compare content
        var contentChanged = (title != viewModel.postForEdit?.document?.attributes?.title)
        contentChanged = contentChanged || (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
        if !contentChanged && hintType == nil {hintType = .error("content wasn't changed".localized().uppercaseFirst)}
        return titleAndContentAreNotEmpty && titleIsInsideLimit && contentInsideLimit && contentChanged
    }
    
    var viewModel: PostEditorViewModel {
        fatalError("Must override")
    }
    
    var postTitle: String? { titleTextView.text }
    
    // MARK: - Subviews
    // community
    lazy var communityView = UIView(forAutoLayout: ())
    lazy var youWillPostInLabel = UILabel.descriptionLabel("you will post in".localized().uppercaseFirst)
    lazy var communityAvatarImage = MyAvatarImageView(size: 40)
    lazy var communityNameLabel = UILabel.with(text: "hint type choose community".localized().uppercaseFirst, textSize: 15, weight: .semibold, numberOfLines: 0)
    lazy var titleTextView: UITextView = {
        let titleTextView = UITextView(forExpandable: ())
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.typingAttributes = [.font: UIFont.systemFont(ofSize: 21, weight: .bold)]
        titleTextView.placeholder = "title placeholder".localized().uppercaseFirst
        titleTextView.delegate = self
        return titleTextView
    }() 
    lazy var titleTextViewCountLabel = UILabel.descriptionLabel("0/240")
    lazy var contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    
    var contentTextView: ContentTextView {
        fatalError("Must override")
    }
    
    // MARK: - Initializers
    init(post: ResponseAPIContentGetPost? = nil, community: ResponseAPIContentGetCommunity? = nil, chooseCommunityAfterLoading: Bool = true, parseDraftAfterLoading: Bool = true) {
        self.chooseCommunityAfterLoading = chooseCommunityAfterLoading
        self.parseDraftAfterLoading = parseDraftAfterLoading
        super.init(nibName: nil, bundle: nil)
        viewModel.postForEdit = post
        viewModel.community.accept(community)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            if hasDraft && parseDraftAfterLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // your code here
                    self.retrieveDraft()
                }
            } else {
                if viewModel.community.value == nil && chooseCommunityAfterLoading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.chooseCommunityDidTouch()
                    }
                }
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        
        actionButton.isDisabled = true
        actionButton.backgroundColor = .appMainColor
        actionButton.setTitle("send post".localized().uppercaseFirst, for: .normal)
        
        // titleTextView
        titleTextViewCountLabel.isHidden = true
        
        // common contentTextView
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        headerLabel.text = (viewModel.postForEdit != nil ? "edit" : "create").localized().uppercaseFirst + " " + "post".localized()
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 100, right: 16)
        
        contentTextView.addLinkDidTouch = { [weak self] in
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
        
        bindTitleTextView()
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
        titleTextView.rx.text.onNext(post.document?.attributes?.title)
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
