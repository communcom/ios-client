//
//  FeedPageHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 12/11/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class FeedPageHeaderView: MyTableHeaderView {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
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
        
        let postingView = UIView(backgroundColor: .white)
        addSubview(postingView)

        postingView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        
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
        
        if completion != nil {
            editorVC.chooseCommunityAfterLoading = false
        }
        
        parentViewController?.present(editorVC, animated: true, completion: {
            completion?(editorVC)
        })
    }

}
