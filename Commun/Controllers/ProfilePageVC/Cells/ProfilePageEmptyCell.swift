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
    @IBOutlet weak var emptyImageView: UIImageView!
    
    
    func setUp(with segmentedItem: ProfilePageSegmentioItem) {
        switch segmentedItem {
        case .posts:
            titleLabel.text = "No Posts".localized()
            descriptionLabel.text = "You have not made any".localized() + " " + "post".localized()
            emptyImageView.image = UIImage(named: "ProfilePageItemsEmptyPost")
        case .comments:
            titleLabel.text = "No Comments".localized()
            descriptionLabel.text = "You have not made any".localized() + " " + "comment".localized()
            emptyImageView.image = UIImage(named: "ProfilePageItemsEmptyComment")
        }
    }

}
