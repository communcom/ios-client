//
//  TextContentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class TextContentCell: UITableViewCell {

@IBOutlet weak var titleLabel: UILabel!
@IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupFromPost(_ post: ResponseAPIContentGetPost) {
        titleLabel.text = post.content.title
        contentLabel.text = post.content.body.full
    }
}
