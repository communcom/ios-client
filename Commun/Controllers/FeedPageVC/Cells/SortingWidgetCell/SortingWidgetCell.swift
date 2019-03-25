//
//  SortingWidgetCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 18/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

enum FeedType: String {
    case new = "New"
    case top = "Top"
}


protocol SortingWidgetDelegate {
    func sortingWidget(_ widget: SortingWidgetCell, didSelectFeedTypeButton withTypes: [FeedType])
    func sortingWidget(_ widget: SortingWidgetCell, didSelectSortTimeButton withSortTypes: [FeedTimeFrameMode])
}

class SortingWidgetCell: UITableViewCell {

    @IBOutlet weak var feedTypeButton: UIButton!
    @IBOutlet weak var sortTimeButton: UIButton!
    
    var delegate: SortingWidgetDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedTypeButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        sortTimeButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        feedTypeButton.layer.borderWidth = 1.0
        sortTimeButton.layer.borderWidth = 1.0
        
        feedTypeButton.layer.cornerRadius = 4.0
        sortTimeButton.layer.cornerRadius = 4.0
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFeedType(withType type: FeedType) {
        feedTypeButton.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        feedTypeButton.setTitle(type.rawValue, for: .normal)
    }
    
    func setSortType(withType type: FeedTimeFrameMode) {
        sortTimeButton.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        sortTimeButton.setTitle(type.rawValue, for: .normal)
    }

    @IBAction func didTapFeedTypeButton(_ sender: Any) {
        delegate?.sortingWidget(self, didSelectFeedTypeButton: [])
    }
    
    @IBAction func didTapSortTimeButton(_ sender: Any) {
        delegate?.sortingWidget(self, didSelectSortTimeButton: [])
    }
    
}
