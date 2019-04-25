//
//  PasswordCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class PasswordCell: UITableViewCell {
    
    @IBOutlet weak var passwordsTypeLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func copyPasswordButtonTap(_ sender: Any) {
        
    }
    
}
