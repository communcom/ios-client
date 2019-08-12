//
//  ProfilePageEmptyCell.swift
//  Commun
//
//  Created by Chung Tran on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {
    @IBOutlet weak var emptyView: EmptyView!
    
    
    func setUp(with segmentedItem: ProfilePageSegmentioItem) {
        emptyView.setUp(with: segmentedItem)
    }
    
    func setUpEmptyComment() {
        emptyView.setUpEmptyComment()
    }
    
    func setUpEmptyPost() {
        emptyView.setUpEmptyPost()
    }
}
