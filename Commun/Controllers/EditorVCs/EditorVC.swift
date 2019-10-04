//
//  EditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class EditorVC: UIViewController {
    // MARK: - Subviews
    // header
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    lazy var headerLabel = UILabel.title("create post".localized().uppercaseFirst)
    // community
    lazy var communityAvatarImage = UIImageView.circle(size: 40)
    lazy var youWillPostIn = UILabel.descriptionLabel("you will post in".localized().uppercaseFirst)
    lazy var communityNameLabel = UILabel.with(text: "Overwatch", textSize: 15, weight: .semibold)
    lazy var dropdownButton = UIButton.circleGray(imageName: "drop-down")
    // TODO: - Content
    
    // Toolbar
    lazy var toolbar = UIView(height: 55)
    lazy var postButton = StepButton(height: 36, label: "post".localized().uppercaseFirst, textColor: .white, cornerRadius: 18, contentInsets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        view.backgroundColor = .white
        
        layoutSubviews()
    }
    
    func layoutSubviews() {
        // add scrollview
        let scrollView = UIScrollView(forAutoLayout: ())
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea()
        
        // add childview of scrollview
        let contentView = UIView(forAutoLayout: ())
        scrollView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        // fix contentView
        contentView.addSubview(closeButton)
        contentView.addSubview(headerLabel)
        closeButton.autoPinEdge(toSuperviewEdge: .top, withInset: 25)
        closeButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        headerLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        headerLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
        
        
        closeButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
}
