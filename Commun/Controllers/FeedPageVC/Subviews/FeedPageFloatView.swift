//
//  FeedPageHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

final class FeedPageFloatView: MyView {

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
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        backgroundColor = .appMainColor
        
        addSubview(headerLabel)
        headerLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 0), excludingEdge: .trailing)
        
        addSubview(changeFeedTypeButton)
        changeFeedTypeButton.autoPinEdge(.leading, to: .trailing, of: headerLabel, withOffset: 16 * Config.heightRatio)
        changeFeedTypeButton.autoAlignAxis(.horizontal, toSameAxisOf: headerLabel, withOffset: 3 * Config.heightRatio)
        
        changeFeedTypeButton.addTarget(self, action: #selector(changeFeedTypeButtonDidTouch(_:)), for: .touchUpInside)
        
        addSubview(sortButton)
        sortButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        sortButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        sortButton.addTarget(self, action: #selector(changeFilterButtonDidTouch(_:)), for: .touchUpInside)
    }
    
    func setUp(with filter: PostsListFetcher.Filter) {
        // feedTypeMode
        switch filter.feedTypeMode {
        case .subscriptions:
            headerLabel.text = String(format: "%@ %@", "my".localized().uppercaseFirst, "feed".localized().uppercaseFirst)
            changeFeedTypeButton.setTitle("trending".localized().uppercaseFirst, for: .normal)
        case .hot, .new:
            headerLabel.text = "trending".localized().uppercaseFirst
            changeFeedTypeButton.setTitle(String(format: "%@ %@", "my".localized().uppercaseFirst, "feed".localized().uppercaseFirst), for: .normal)
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
}
