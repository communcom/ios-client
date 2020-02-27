//
//  SendPointListVC.swift
//  Commun
//
//  Created by Chung Tran on 12/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class SendPointListVC: SubscriptionsVC {
    // MARK: - Properties
    var completion: ((ResponseAPIContentGetProfile) -> Void)?
    
    // MARK: - Initializers
    init() {
        super.init(title: "send points".localized().uppercaseFirst, type: .user)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func configureCell(with subscription: ResponseAPIContentGetSubscriptionsItem, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(with: subscription, indexPath: indexPath) as! SubscriptionsUserCell
        cell.hideActionButton()
        return cell
    }
    
    override func modelSelected(_ item: ResponseAPIContentGetSubscriptionsItem) {
        guard let user = item.userValue else {return}
        self.completion?(user)
    }
}
