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
    // community
    lazy var communityAvatarImage = UIImageView.circle(size: 40, imageName: "tux")
    lazy var youWillPostIn = UILabel.descriptionLabel("you will post in".localized().uppercaseFirst)
    lazy var communityNameLabel = UILabel.with(text: "Commun", textSize: 15, weight: .semibold)
    lazy var dropdownButton = UIButton.circleGray(imageName: "drop-down")
    lazy var contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // add default tool
        appendTool(EditorToolbarItem.addPhoto)
        
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
    
    override func setUp() {
        super.setUp()
        actionButton.setTitle("send post".localized().uppercaseFirst, for: .normal)
        actionButton.backgroundColor = .appMainColor
        
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
    
    override func bind() {
        super.bind()
        tools
            .bind(to: buttonsCollectionView.rx.items(
                cellIdentifier: "EditorToolbarItemCell", cellType: EditorToolbarItemCell.self))
                { (index, item, cell) in
                    cell.setUp(item: item)
                }
            .disposed(by: disposeBag)
        
        buttonsCollectionView.rx
            .modelSelected(EditorToolbarItem.self)
            .subscribe(onNext: { [unowned self] item in
                self.didSelectTool(item)
            })
            .disposed(by: disposeBag)
        
        buttonsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        bindKeyboardHeight()
        
        bindSendPostButton()
        
        bindContentTextView()
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
