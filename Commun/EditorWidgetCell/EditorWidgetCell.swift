//
//  EditorWidgetCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol EditorWidgetDelegate {
    func editorWidgetDidTapInputButton()
    func editorWidgetDidTapMediaButton()
}

class EditorWidgetCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!

    var delegate: EditorWidgetDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    
    @IBAction func inputButtonTap(_ sender: Any) {
        delegate?.editorWidgetDidTapInputButton()
    }
 
    @IBAction func mediaButtonTap(_ sender: Any) {
        delegate?.editorWidgetDidTapMediaButton()
    }
    
}
