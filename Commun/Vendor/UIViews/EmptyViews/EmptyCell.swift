//
//  ProfilePageEmptyCell.swift
//  Commun
//
//  Created by Chung Tran on 22/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {
    @IBOutlet weak var emptyView: EmptyView!
    
    func setUpEmptyComment() {
        emptyView.setUpEmptyComment()
    }
    
    func setUpEmptyPost() {
        emptyView.setUpEmptyPost()
    }
}
