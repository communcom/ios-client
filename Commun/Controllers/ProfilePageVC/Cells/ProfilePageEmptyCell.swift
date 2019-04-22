//
//  ProfilePageEmptyCell.swift
//  Commun
//
//  Created by Chung Tran on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class ProfilePageEmptyCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setUp(with segmentedItem: ProfilePageSegmentioItem) {
        switch segmentedItem {
        case .posts:
            titleLabel.text = "No Posts".localized()
            descriptionLabel.text = "You have not made any".localized() + " " + "post".localized()
        case .comments:
            titleLabel.text = "No Comments".localized()
            descriptionLabel.text = "You have not made any".localized() + " " + "comment".localized()
        }
    }

}
