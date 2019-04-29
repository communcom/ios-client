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
        
        let sortWidget = tableView.dequeueReusableCell(withIdentifier: "SortingWidgetCell") as! SortingWidgetCell
        sortWidget.delegate = self
        resultCells.append(sortWidget)
        
        switch viewModel.sortType.value {
        case .day:
            sortWidget.sortTimeButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            sortWidget.sortTimeButton.setTitle("Past 24 hours", for: .normal)
        case .week:
            sortWidget.sortTimeButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            sortWidget.sortTimeButton.setTitle("Past Week", for: .normal)
        case .month:
            sortWidget.sortTimeButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            sortWidget.sortTimeButton.setTitle("Past Month", for: .normal)
        case .year:
            sortWidget.sortTimeButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            sortWidget.sortTimeButton.setTitle("Past Year", for: .normal)
        case .all:
            sortWidget.sortTimeButton.backgroundColor = .white
            sortWidget.sortTimeButton.setTitle("Off All Time", for: .normal)
        default:
            break
        }
        
        let editorWidget = tableView.dequeueReusableCell(withIdentifier: "EditorWidgetCell") as! EditorWidgetCell
        editorWidget.delegate = self
        resultCells.append(editorWidget)
        
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
