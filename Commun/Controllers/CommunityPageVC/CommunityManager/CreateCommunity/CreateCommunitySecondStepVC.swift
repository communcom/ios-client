//
//  CreateCommunitySencondStepVC.swift
//  Commun
//
//  Created by Chung Tran on 9/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CMTopicCell: MyTableViewCell {
    
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .clear
        
        let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
        view.borderColor = .appLightGrayColor
        view.borderWidth = 1
        contentView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges(with: .only(.bottom, inset: 16))
    }
}

class CMTopicsVC: CMTableViewController<String, CMTopicCell> {
    override func setUp() {
        super.setUp()
        setUpFooterView()
    }
    
    private func setUpFooterView() {
        // footerView
        let footerView: UIView = {
            let view = UIView(height: 55, backgroundColor: .appWhiteColor, cornerRadius: 10)
            let label = UILabel.with(text: "+ " + "add new topic".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor)
            view.addSubview(label)
            label.autoCenterInSuperview()
            return view
                .onTap(self, action: #selector(addTopicButtonDidTouch))
        }()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 71))
        view.addSubview(footerView)
        footerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        tableView.tableFooterView = view
    }
    
    @objc func addTopicButtonDidTouch() {
        
    }
}

class CreateTopicsVC: CMTopicsVC, CreateCommunityVCType {
    let isDataValid = BehaviorRelay<Bool>(value: false)
    
    override var contentInsets: UIEdgeInsets {UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)}
    
    override func setUp() {
        super.setUp()
        setUpHeaderView()
    }
    
    override func bind() {
        super.bind()
        
    }
    
    private func setUpHeaderView() {
        let headerView = MyTableHeaderView(tableView: tableView)
        let stackView = UIStackView(axis: .vertical, spacing: 30, alignment: .center, distribution: .fill)
        headerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
        
        let label = UILabel.with(text: "topics are needed for recomendation service. In that way, for users, interested in your community will by much easier to find itin a list.".localized().uppercaseFirst, textSize: 15, numberOfLines: 0, textAlignment: .center)
        stackView.addArrangedSubviews([
            UIImageView(width: 120, height: 120, cornerRadius: 60, imageNamed: "topic-explaination"),
            label
        ])
        label.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
    
    
}
