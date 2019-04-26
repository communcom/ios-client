//
//  ChangePasswordCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol ChangePasswordCellDelegate {
    func changePasswordDidTap()
}

class ChangePasswordCell: UITableViewCell {

    var delegate: ChangePasswordCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func changePasswordButtonTap(_ sender: Any) {
        delegate?.changePasswordDidTap()
    }
    
}
