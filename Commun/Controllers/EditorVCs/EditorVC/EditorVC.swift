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
    
    var shouldSendPost: Bool {
        let content = contentTextView.text ?? ""
        
        // both title and content are not empty
        let contentAreNotEmpty = !content.isEmpty
        
        // content inside limit
        let contentInsideLimit = (content.count <= contentLettersLimit)
        
        // compare content
        let contentChanged = (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
        
        // reassign result
        return contentAreNotEmpty && contentInsideLimit && contentChanged
    }
    
    var contentTextView: ContentTextView {
        fatalError("Must override")
    }
    
    var contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    
    var viewModel: EditorViewModel {
        fatalError("Must override")
    }
    
    var postTitle: String? {
        fatalError("Must override")
    }
    
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
        
        contentTextView.setColorDidTouch = {[weak self] in
            guard let strongSelf = self else {return}
            strongSelf.didSelectTool(.setColor)
        }
    }
    
    // MARK: - action for overriding
    func setUp(with post: ResponseAPIContentGetPost) {
        contentTextView.parseContentBlock(post.content)
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
