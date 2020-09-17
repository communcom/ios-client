//
//  TopicsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

extension String: ListItemType {
    public func newUpdatedItem(from item: String) -> String? {item}
}

class TopicsVC: CMTableViewController<String, TopicCell> {
    // MARK: - Properties
    let communityCode: String
    let communityIssuer: String
    
    // MARK: - Initializers
    init(communityCode: String, communityIssuer: String, topics: [String]) {
        self.communityCode = communityCode
        self.communityIssuer = communityIssuer
        var topics = topics
        topics.removeDuplicates()
        super.init(originalItems: topics)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "topics".localized().uppercaseFirst
        
        // footerView
        let footerView: UIView = {
            let view = UIView(height: 57, backgroundColor: .appWhiteColor, cornerRadius: 10)
            let label = UILabel.with(text: "+ " + "add new topic".localized().uppercaseFirst, textSize: 17, weight: .medium, textColor: .appMainColor)
            view.addSubview(label)
            label.autoCenterInSuperview()
            
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTopicButtonDidTouch)))
            return view
        }()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 67))
        view.addSubview(footerView)
        footerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
        tableView.tableFooterView = view
    }
    
    override func configureCell(item: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(item: item, indexPath: indexPath) as! TopicCell
        cell.label.text = item
        return cell
    }
    
    @objc func addTopicButtonDidTouch() {
        
    }
}
