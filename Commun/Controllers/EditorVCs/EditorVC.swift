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
    let disposeBag = DisposeBag()
    
    let tools = BehaviorRelay<[EditorToolbarItem]>(value: [
        EditorToolbarItem(name: "18+", icon: "18Button", iconSize: CGSize(width: 23, height: 12), description: nil, isHighlighted: false, action: {
            print("18+")
        }),
        EditorToolbarItem(name: "open-photo", icon: "editor-open-photo", iconSize: CGSize(width: 18, height: 18), description: nil, isHighlighted: false, action: {
            print("18+")
        })
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
    }
    
    func setUpViews() {
        // toolbars
        setUpToolbar()
        
        // add scrollview
        let scrollView = UIScrollView(forAutoLayout: ())
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        scrollView.autoPinEdge(.bottom, to: .top, of: toolbar)
        
        // add childview of scrollview
        contentView = UIView(forAutoLayout: ())
        scrollView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        // fix contentView
        layoutContentView()
        pinContentViewBottom()
        
        // bind
        bind()
    }
    
    func setUpToolbar() {
        view.addSubview(toolbar)
//        toolbar.addShadow(offset: CGSize(width: 0, height: -10))
        toolbar.autoPinEdge(toSuperviewSafeArea: .leading)
        toolbar.autoPinEdge(toSuperviewSafeArea: .trailing)
        let keyboardViewV = KeyboardLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        // buttons
        setUpToolbarButtons()
        
        // sendpost button
        toolbar.addSubview(postButton)
        postButton.autoPinEdge(.leading, to: .trailing, of: buttonsCollectionView, withOffset: 10)
        postButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        postButton.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    func setUpToolbarButtons() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        buttonsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        buttonsCollectionView.showsHorizontalScrollIndicator = false
        buttonsCollectionView.backgroundColor = .clear
        buttonsCollectionView.configureForAutoLayout()
        toolbar.addSubview(buttonsCollectionView)
        // layout
        buttonsCollectionView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 0), excludingEdge: .right)
        buttonsCollectionView.register(EditorToolbarItemCell.self, forCellWithReuseIdentifier: "EditorToolbarItemCell")
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
        
    }
    
    func pinContentViewBottom() {
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
        
        buttonsCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}
