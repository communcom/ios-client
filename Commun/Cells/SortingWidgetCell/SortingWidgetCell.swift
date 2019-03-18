//
//  SortingWidgetCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 18/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

enum FeedType: String {
    case new = "New"
    case top = "Top"
}

enum SortTimeType: String {
    case past24 = "Past 24 hours"
    case pastWeek = "Past week"
    case pastMonth = "Past month"
    case pastYear = "Past year"
    case allTile = "Of all tile"
}

protocol SortingWidgetDelegate {
    func sortingWidget(_ widget: SortingWidgetCell, didSelectFeedTypeButton withTypes: [FeedType])
    func sortingWidget(_ widget: SortingWidgetCell, didSelectSortTimeButton withSortTypes: [SortTimeType])
}

class SortingWidgetCell: UITableViewCell {

    @IBOutlet weak var feedTypeButton: UIButton!
    @IBOutlet weak var sortTimeButton: UIButton!
    
    var delegate: SortingWidgetDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedTypeButton.layer.borderColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        sortTimeButton.layer.borderColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        
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
    
    func setSortType(withType type: SortTimeType) {
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
