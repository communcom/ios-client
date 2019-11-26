//
//  FTUECommunitiesVC.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class FTUECommunitiesVC: BaseViewController {
    // MARK: - Constants
    let bottomBarHeight: CGFloat = 114
    
    // MARK: - Properties
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(forAutoLayout: ())
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "search".localized().uppercaseFirst
        return searchBar
    }()

    // bottomBar
    private lazy var shadowView = UIView(height: bottomBarHeight)
    lazy var bottomBar = UIView(backgroundColor: .white)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        // titleLabel
        let titleLabel = UILabel.with(text: "get you first points".localized().uppercaseFirst, textSize: 33, weight: .bold, numberOfLines: 0)
        view.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        // descriptionLabel
        let descriptionLabel = UILabel.with(textSize: 17, textColor: .a5a7bd, numberOfLines: 0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        let attrString = NSAttributedString(string: "subscribe to at least 3 communities and get your first Community Points".localized().uppercaseFirst, attributes: [.paragraphStyle: paragraphStyle])
        descriptionLabel.attributedText = attrString
        view.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // searchBar
        view.addSubview(searchBar)
        searchBar.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 25)
        searchBar.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        searchBar.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        
        // collection view
        
        // bottomBar
        view.addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        shadowView.addShadow(ofColor: .shadow, radius: 4, offset: CGSize(width: 0, height: -6), opacity: 0.1)
        
        shadowView.addSubview(bottomBar)
        bottomBar.autoPinEdgesToSuperviewEdges()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        shadowView.layoutIfNeeded()
        bottomBar.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 24.5)
    }
}
