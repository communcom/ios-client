//
//  EditorMediaCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 02/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class EditorMediaCell: UITableViewCell {

    @IBOutlet weak var pictureImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeButtonTap(_ sender: Any) {
        
    }
    
}
