//
//  CommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class CommunityCell: UITableViewCell {
    // MARK: - Properties
    var community: MockupCommunity!
    @IBOutlet weak var communityImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    func setUp(community: MockupCommunity) {
        // assign community
        self.community = community
        
        // set up views
        communityImageView.image    = community.icon
        nameLabel.text              = community.name
        setUpDidJoin()
    }
    
    func setUpDidJoin() {
        let joined = self.community.joined
        
        joinButton.setTitle(joined ? "JOINED".localized(): "JOIN".localized(), for: .normal)
        joinButton.backgroundColor = joined ? UIColor(hexString: "#F3F5FA") : UIColor.appMainColor
        joinButton.setTitleColor(joined ? .darkGray : .white, for: .normal)
    }

    @IBAction func joinButtonDidTouch(_ sender: Any) {
        self.community.joined = !self.community.joined
        setUpDidJoin()
    }
}
