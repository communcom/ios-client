//
//  CreateRulesVC.swift
//  Commun
//
//  Created by Chung Tran on 9/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CreateRulesVC: CMRulesVC, CreateCommunityVCType {
    let isDataValid = BehaviorRelay<Bool>(value: false)
    
//    override var contentInsets: UIEdgeInsets {UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)}
    
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
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        
        let label = UILabel.with(text: "We’ve added some default rules for your community.\nYou can edit, remove or add new rules for this community.".localized().uppercaseFirst, textSize: 15, numberOfLines: 0, textAlignment: .center)
        let spacer = UIView.spacer(height: 1, backgroundColor: .e2e6e8)
        stackView.addArrangedSubviews([
            label,
            spacer
        ])
        spacer.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
    }
}
