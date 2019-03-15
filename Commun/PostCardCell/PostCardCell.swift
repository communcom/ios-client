//
//  PostCardCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol PostCardCellDelegate {
    // Делагат еще буду дорабатывать по мере работы над информацией.
    func didTapMenuButton()
    func didTapUpButton()
    func didTapDownButton()
    func didTapShareButton()
}

class PostCardCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var likeCounterLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var numberOfSharesLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    
    var delegate: PostCardCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func menuButtonTap(_ sender: Any) {
        delegate?.didTapMenuButton()
    }
    
    @IBAction func upButtonTap(_ sender: Any) {
        delegate?.didTapUpButton()
    }
    
    @IBAction func downButtonTap(_ sender: Any) {
        delegate?.didTapDownButton()
    }
    
    @IBAction func shareButtonTap(_ sender: Any) {
        delegate?.didTapShareButton()
    }
}
