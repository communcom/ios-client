//
//  EditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EditorVC: BaseViewController {
    // MARK: - Constant
    
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let tools = BehaviorRelay<[EditorToolbarItem]>(value: [])
    
    // MARK: - Subviews
    // header
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    lazy var headerLabel = UILabel.title("create post".localized().uppercaseFirst)
    
    // Content
    lazy var contentView = UIView(forAutoLayout: ())
    
    // Toolbar
    lazy var toolbar: UIView = {
        let toolbar = UIView(backgroundColor: .white, cornerRadius: 16)
        toolbar.addShadow(ofColor: UIColor(red: 56, green: 60, blue: 71)!, radius: 16, offset: CGSize(width: 0, height: -6), opacity: 0.07)
        return toolbar
    }()
    
    var buttonsCollectionView: UICollectionView!
    
    // PostButton
    lazy var actionButton = CommunButton(
        height: 36,
        label: "send".localized().uppercaseFirst,
        labelFont: .systemFont(ofSize: 15, weight: .semibold),
        backgroundColor: .appMainColor,
        textColor: .white,
        cornerRadius: 18,
        contentInsets: UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16))
    
    override func setUp() {
        super.setUp()
        
        view.backgroundColor = .white
        
        // navigation bar
        let navigationBar = UIView(height: 44, backgroundColor: .white)
        view.addSubview(navigationBar)
        navigationBar.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        
        // close button
        navigationBar.addSubview(closeButton)
        closeButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        closeButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        // header
        navigationBar.addSubview(headerLabel)
        headerLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        headerLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
        
        
        // scrollView
        let scrollView = UIScrollView(forAutoLayout: ())
        view.addSubview(scrollView)
        scrollView.autoPinEdge(.top, to: .bottom, of: navigationBar)
        scrollView.autoPinEdge(toSuperviewEdge: .leading)
        scrollView.autoPinEdge(toSuperviewEdge: .trailing)
       
        // add childview of scrollview
        scrollView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        // layout contentView
        layoutContentView()
        
        // toolBar
        view.addSubview(toolbar)
        toolbar.autoPinEdge(toSuperviewSafeArea: .leading)
        toolbar.autoPinEdge(toSuperviewSafeArea: .trailing)
        toolbar.autoSetDimension(.height, toSize: 55 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0))
        let keyboardViewV = KeyboardLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        setUpToolbarButtons()
        
        // action button
        toolbar.addSubview(actionButton)
        actionButton.autoPinEdge(.leading, to: .trailing, of: buttonsCollectionView, withOffset: 10)
        actionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        actionButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        actionButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        
        // scrollView to toolbar
        scrollView.autoPinEdge(.bottom, to: .top, of: toolbar, withOffset: -12)
    }
    
    override func bind() {
        super.bind()
        tools
            .bind(to: buttonsCollectionView.rx.items(
                cellIdentifier: "EditorToolbarItemCell", cellType: EditorToolbarItemCell.self)) { (index, item, cell) in
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
        buttonsCollectionView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        buttonsCollectionView.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        buttonsCollectionView.autoSetDimension(.height, toSize: 35)
        
        buttonsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        buttonsCollectionView.register(EditorToolbarItemCell.self, forCellWithReuseIdentifier: "EditorToolbarItemCell")
    }
    
    func didSelectTool(_ item: EditorToolbarItem) {
        guard item.isEnabled else {return}
        
        if item == .hideKeyboard {
            hideKeyboard()
        }
    }
}
