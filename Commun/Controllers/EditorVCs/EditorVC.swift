//
//  EditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EditorVC: UIViewController {
    // MARK: - Properties
    let contentLettersLimit = 30000
    let disposeBag = DisposeBag()
    
    var contentCombined: Observable<Void> {
        fatalError("Must override")
    }
    
    #warning("Must override in ArticleVC")
    var shouldSendPost: Bool {
        let content = contentTextView.text ?? ""
        
        // both title and content are not empty
        let contentAreNotEmpty = !content.isEmpty
        
        // compare content
        let contentChanged = (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
        
        // reassign result
        return contentAreNotEmpty && contentChanged
    }
    
    var contentTextView: ContentTextView {
        fatalError("Must override")
    }
    
    var contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    
    var viewModel = EditorViewModel()
    
    let tools = BehaviorRelay<[EditorToolbarItem]>(value: [
        EditorToolbarItem.toggleIsAdult,
        EditorToolbarItem.addPhoto
    ]) 
    
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
    
    // Toolbar
    lazy var toolbar = UIView(height: 55)
    var buttonsCollectionView: UICollectionView!
    
    // PostButton
    lazy var postButton = CommunButton(
        height: 36,
        label: "post".localized().uppercaseFirst,
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
    }
    
    func setUpViews() {
        // close button
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        // toolbars
        setUpToolbar()
        
        // add scrollview
        addScrollView()
        
        // fix contentView
        layoutContentView()
        
        // common contentTextView
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        headerLabel.text = (viewModel.postForEdit != nil ? "edit post" : "create post").localized().uppercaseFirst
        
        // if editing post
        if let post = viewModel.postForEdit {
            parsePost(post)
        }
        else {
            // parse draft
            if hasDraft {
                retrieveDraft()
            }
        }
    }
    
    func layoutContentView() {
        // header
        contentView.addSubview(closeButton)
        contentView.addSubview(headerLabel)
        closeButton.autoPinEdge(toSuperviewEdge: .top, withInset: 25)
        closeButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        headerLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        headerLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
        
        // community
        contentView.addSubview(communityAvatarImage)
        contentView.addSubview(youWillPostIn)
        contentView.addSubview(communityNameLabel)
        contentView.addSubview(dropdownButton)
        
        communityAvatarImage.autoPinEdge(.top, to: .bottom, of: closeButton, withOffset: 25)
        communityAvatarImage.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        youWillPostIn.autoPinEdge(.top, to: .top, of: communityAvatarImage, withOffset: 5)
        youWillPostIn.autoPinEdge(.leading, to: .trailing, of: communityAvatarImage, withOffset: 10)
        
        communityNameLabel.autoPinEdge(.leading, to: .trailing, of: communityAvatarImage, withOffset: 10)
        communityNameLabel.autoPinEdge(.bottom, to: .bottom, of: communityAvatarImage, withOffset: -4)
        
        dropdownButton.autoAlignAxis(.horizontal, toSameAxisOf: communityAvatarImage)
        dropdownButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // textView
        contentView.addSubview(contentTextView)
        
        layoutTopContentTextView()
        layoutContentTextView()
        layoutBottomContentTextView()
    }
    
    func layoutTopContentTextView() {
        fatalError("Must override")
    }
    
    func layoutContentTextView() {
        contentTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        contentTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // forward delegate
        contentTextView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // countlabel
        contentView.addSubview(contentTextViewCountLabel)
        contentTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: -12)
        contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
    
    func layoutBottomContentTextView() {
        fatalError("Must override this method")
    }
    
    func bind() {
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
    
    func didSelectTool(_ item: EditorToolbarItem) {
        guard item.isEnabled else {return}
        
        if item == .hideKeyboard {
            hideKeyboard()
        }
        
        if item == .addPhoto {
            addImage()
        }
        
        if item == .toggleIsAdult {
            viewModel.isAdult = !item.isHighlighted
            toggleIsHighlightedForTool(item)
        }
        
        if item == .setBold {
            contentTextView.toggleBold()
        }
        
        if item == .setItalic {
            contentTextView.toggleItalic()
        }
        
        if item == .addLink {
            addLink()
        }
        
        if item == .clearFormatting {
            contentTextView.clearFormatting()
        }
        
        if item == .setColor {
            pickColor(sender: buttonsCollectionView)
        }
    }
    
    // MARK: - action for overriding
    func setUp(with post: ResponseAPIContentGetPost) {
        try? contentTextView.parseText(post.content.body.full!)
    }
    
    func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        fatalError("Must override")
    }
    
    func didAddImageFromURLString(_ urlString: String, description: String? = nil) {
        fatalError("Must override")
    }
    
    func didAddLink(_ urlString: String, placeholder: String? = nil) {
        fatalError("Must override")
    }
    
    var hasDraft: Bool {
        return contentTextView.hasDraft
    }
    
    func getDraft() {
        // retrieve content
        contentTextView.getDraft {
            // remove draft
            self.removeDraft()
        }
    }
    
    func saveDraft(completion: (()->Void)? = nil) {
        // save content
        contentTextView.saveDraft(completion: completion)
    }
    
    #warning("Must override in ArticleVC")
    func removeDraft() {
        contentTextView.removeDraft()
    }
}
