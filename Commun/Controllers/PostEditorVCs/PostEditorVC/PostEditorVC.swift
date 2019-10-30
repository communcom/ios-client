//
//  PostEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PostEditorVC: EditorVC {
    // MARK: - Properties
    override var contentLettersLimit: UInt {30000}
    
    var viewModel: PostEditorViewModel {
        fatalError("Must override")
    }
    
    var postTitle: String? {
        fatalError("Must override")
    }
    
    // MARK: - Subviews
    // header
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    lazy var headerLabel = UILabel.title("create post".localized().uppercaseFirst)
    // community
    lazy var communityAvatarImage = UIImageView.circle(size: 40, imageName: "tux")
    lazy var youWillPostIn = UILabel.descriptionLabel("you will post in".localized().uppercaseFirst)
    lazy var communityNameLabel = UILabel.with(text: "Commun", textSize: 15, weight: .semibold)
    lazy var dropdownButton = UIButton.circleGray(imageName: "drop-down")
    // Content
    var contentView: UIView!
    lazy var contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    
    // Toolbar
    lazy var toolbar = UIView(forAutoLayout: ())
    var buttonsCollectionView: UICollectionView!
    
    // PostButton
    lazy var postButton = CommunButton(
        height: 36,
        label: "send post".localized().uppercaseFirst,
        labelFont: .systemFont(ofSize: 15, weight: .semibold),
        backgroundColor: .appMainColor,
        textColor: .white,
        cornerRadius: 18,
        contentInsets: UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16))
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // custom view
        view.backgroundColor = .white
        
        setUpViews()
        
        // bind
        bind()
        
        // add default tool
        appendTool(EditorToolbarItem.addPhoto)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // if editing post
        if let post = viewModel.postForEdit {
            setUp(with: post)
        }
        else {
            // parse draft
            if hasDraft {
                retrieveDraft()
            }
        }
    }
    
    func setUpViews() {
        // close button
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(sendPost), for: .touchUpInside)
        
        // toolbars
        setUpToolbar()
        
        // add scrollview
        addScrollView()
        
        // fix contentView
        layoutContentView()
        
        // common contentTextView
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        headerLabel.text = (viewModel.postForEdit != nil ? "edit post" : "create post").localized().uppercaseFirst
        
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 200, right: 16)
        
        contentTextView.addLinkDidTouch = {[weak self] in
            self?.addLink()
        }
    }
    
    // MARK: - action for overriding
    func setUp(with post: ResponseAPIContentGetPost) {
        contentTextView.parseContentBlock(post.document)
    }
    
    func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        fatalError("Must override")
    }
    
    func didAddLink(_ urlString: String, placeholder: String? = nil) {
        fatalError("Must override")
    }
    
    func getContentBlock() -> Single<ResponseAPIContentBlock> {
        contentTextView.getContentBlock()
    }
}
