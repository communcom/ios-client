//
//  FeedPageVC+Utilites.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension FeedPageVC {
    
    func makeCells() {
        var resultCells: [UITableViewCell] = []
        
        for item in viewModel.items.value {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCardCell") as! PostCardCell
            cell.setupFromPost(item)
            cell.delegate = self
            resultCells.append(cell)
        }
        
        self.cells = resultCells
        tableView.reloadData()
    }
    
}
