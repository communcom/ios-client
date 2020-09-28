//
//  CreateCommunitySencondStepVC.swift
//  Commun
//
//  Created by Chung Tran on 9/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CreateTopicsVC: CMTopicsVC, CreateCommunityVCType {
    let isDataValid = BehaviorRelay<Bool>(value: false)
    
    override var contentInsets: UIEdgeInsets {UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)}
    
    override func setUp() {
        super.setUp()
        setUpHeaderView()
    }
    
    override func bind() {
        super.bind()
        itemsRelay.map {!$0.isEmpty}
            .asDriver(onErrorJustReturn: false)
            .drive(isDataValid)
            .disposed(by: disposeBag)
    }
    
    private func setUpHeaderView() {
        let headerView = MyTableHeaderView(tableView: tableView)
        let stackView = UIStackView(axis: .vertical, spacing: 30, alignment: .center, distribution: .fill)
        headerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
        
        let label = UILabel.with(text: "topics are needed for recomendation service. In that way, for users who interested in your community, will by much easier to find it in a list.".localized().uppercaseFirst, textSize: 15, numberOfLines: 0, textAlignment: .center)
        stackView.addArrangedSubviews([
            UIImageView(width: 120, height: 120, cornerRadius: 60, imageNamed: "topic-explaination"),
            label
        ])
        label.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
}
