//
//  FeedPageHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

final class FeedPageHeaderView: MyTableHeaderView {
    // MARK: - Constants
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
    lazy var headerLabel = UILabel.with(textSize: 30 * Config.heightRatio, weight: .bold, textColor: .white)
    lazy var changeFeedTypeButton: UIButton = {
        let button = UIButton(labelFont: .boldSystemFont(ofSize: 21 * Config.heightRatio), textColor: .white)
        button.alpha = 0.5
        return button
    }()

    lazy var sortButton: UIButton = {
        let button = UIButton.circle(size: 35, backgroundColor: .clear, imageName: "feed-icon-settings", imageEdgeInsets: .zero)
        return button
    }()
    
    lazy var avatarImageView = MyAvatarImageView(size: 35)
    lazy var openEditorWithPhotoImageView: UIImageView = {
        let iv = UIImageView(width: 24, height: 24, imageNamed: "editor-open-photo")
        iv.tintColor = .a5a7bd
        return iv
    }()
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        backgroundColor = #colorLiteral(red: 0.9591314197, green: 0.9661319852, blue: 0.9840201735, alpha: 1)

        let headerView = UIView(backgroundColor: .appMainColor)
        addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        headerView.addSubview(headerLabel)
        headerLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 0), excludingEdge: .trailing)
        
        headerView.addSubview(changeFeedTypeButton)
        changeFeedTypeButton.autoPinEdge(.leading, to: .trailing, of: headerLabel, withOffset: 16 * Config.heightRatio)
        changeFeedTypeButton.autoAlignAxis(.horizontal, toSameAxisOf: headerLabel, withOffset: 3 * Config.heightRatio)
        
        changeFeedTypeButton.addTarget(self, action: #selector(changeFeedTypeButtonDidTouch(_:)), for: .touchUpInside)
        
        headerView.addSubview(sortButton)
        sortButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        sortButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        sortButton.addTarget(self, action: #selector(changeFilterButtonDidTouch(_:)), for: .touchUpInside)
        
        let postingView = UIView(backgroundColor: .white)
        addSubview(postingView)
        postingView.autoPinEdge(.top, to: .bottom, of: headerView, withOffset: 10)
        postingView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0), excludingEdge: .top)
        
        postingView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 0), excludingEdge: .trailing)
        
        avatarImageView.observeCurrentUserAvatar().disposed(by: disposeBag)
        
        let whatsNewLabel = UILabel.with(text: "what's new".localized().uppercaseFirst + "?", textSize: 15, textColor: .a5a7bd)
        postingView.addSubview(whatsNewLabel)
        whatsNewLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        whatsNewLabel.autoPinEdge(toSuperviewEdge: .top)
        whatsNewLabel.autoPinEdge(toSuperviewEdge: .bottom)
        
        whatsNewLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postButtonDidTouch(_:)))
        whatsNewLabel.addGestureRecognizer(tapGesture)
        
        postingView.addSubview(openEditorWithPhotoImageView)
        openEditorWithPhotoImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        openEditorWithPhotoImageView.autoAlignAxis(toSuperviewMarginAxis: .horizontal)
        openEditorWithPhotoImageView.autoPinEdge(.leading, to: .trailing, of: whatsNewLabel, withOffset: 8)
        
        openEditorWithPhotoImageView.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(photoButtonDidTouch(_:)))
        openEditorWithPhotoImageView.addGestureRecognizer(tapGesture2)
    }
    
    func setUp(with filter: PostsListFetcher.Filter) {
        // feedTypeMode
        switch filter.feedTypeMode {
        case .subscriptions:
            headerLabel.text = "my Feed".localized().uppercaseFirst
            changeFeedTypeButton.setTitle("trending".localized().uppercaseFirst, for: .normal)
        case .new:
            headerLabel.text = "trending".localized().uppercaseFirst
            
            changeFeedTypeButton.setTitle("my Feed".localized().uppercaseFirst, for: .normal)
        default:
            break
        }
    }
    
    @objc func changeFeedTypeButtonDidTouch(_ sender: Any) {
        guard let vc = parentViewController as? PostsViewController else {return}
        vc.toggleFeedType()
    }
    
    @objc func changeFilterButtonDidTouch(_ sender: Any) {
        guard let vc = parentViewController as? PostsViewController else {return}
        vc.openFilterVC()
    }
    
    @objc func postButtonDidTouch(_ sender: Any) {
        openEditor()
    }
    
    @objc func photoButtonDidTouch(_ sender: Any) {
        openEditor { (editorVC) in
            editorVC.addImage()
        }
    }
    
    func openEditor(completion: ((BasicEditorVC)->Void)? = nil) {
        let editorVC = BasicEditorVC()
        editorVC.modalPresentationStyle = .fullScreen
        parentViewController?.present(editorVC, animated: true, completion: {
            completion?(editorVC)
        })
    }
}
