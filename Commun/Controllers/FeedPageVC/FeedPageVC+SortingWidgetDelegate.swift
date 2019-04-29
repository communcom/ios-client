//
//  FeedPageVC+SortingWidgetDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
@_exported import CyberSwift

extension FeedPageVC: SortingWidgetDelegate {
    
    func sortingWidget(_ widget: SortingWidgetCell, didSelectFeedTypeButton withTypes: [FeedType]) {
        showActionSheet(actions: [
            UIAlertAction(title: FeedType.top.rawValue, style: .default, handler: { _ in
                self.showAlert(title: "TODO", message: "FILTER")
            }),
            UIAlertAction(title: FeedType.new.rawValue, style: .default, handler: { _ in
                self.showAlert(title: "TODO", message: "FILTER")
            })])
    }
    
    func sortingWidget(_ widget: SortingWidgetCell, didSelectSortTimeButton withSortTypes: [FeedTimeFrameMode]) {
        showActionSheet(actions: [
            UIAlertAction(title: "Past 24 hours", style: .default, handler: { _ in
                self.viewModel.sortType.accept(.day)
            }),
            UIAlertAction(title: "Past Week", style: .default, handler: { _ in
                self.viewModel.sortType.accept(.week)
            }),
            UIAlertAction(title: "Past Month", style: .default, handler: { _ in
                self.viewModel.sortType.accept(.month)
            }),
            UIAlertAction(title: "Past Year", style: .default, handler: { _ in
                self.viewModel.sortType.accept(.year)
            }),
            UIAlertAction(title: "Of All Time", style: .default, handler: { _ in
                self.viewModel.sortType.accept(.all)
            })
        ])
    }
    
    
}
