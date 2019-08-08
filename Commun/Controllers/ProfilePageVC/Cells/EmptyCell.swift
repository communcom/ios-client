//
//  ProfilePageEmptyCell.swift
//  Commun
//
//  Created by Chung Tran on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emptyImageView: UIImageView!
    
    
    func setUp(with segmentedItem: ProfilePageSegmentioItem) {
        switch segmentedItem {
        case .posts:
            setUpEmptyPost()
        case .comments:
            setUpEmptyComment()
        }
    }
    
    func setUpEmptyComment() {
        titleLabel.text = "no comments".localized().uppercaseFirst
        descriptionLabel.text = String(format: "%@ %@", "you have not made any".localized().uppercaseFirst, "comment".localized())
        emptyImageView.image = UIImage(named: "ProfilePageItemsEmptyComment")
    }
    
    func setUpEmptyPost() {
        titleLabel.text = "no posts".localized().uppercaseFirst
        descriptionLabel.text = String(format: "%@ %@", "you have not made any".localized().uppercaseFirst, "post".localized())
        emptyImageView.image = UIImage(named: "ProfilePageItemsEmptyPost")
    }

}
