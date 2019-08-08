//
//  NotificationsPage+EmptyDataSet.swift
//  Commun
//
//  Created by Chung Tran on 04/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import DZNEmptyDataSet

extension NotificationsPageVC: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "notifications")
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return dataSource.isEmpty
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let message = String(format: "%@!", (viewModel.lastError.value == nil ? "no notification" : "error").localized().uppercaseFirst)
        return NSMutableAttributedString()
            .bold(message, font: .boldSystemFont(ofSize: 22))
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let message = viewModel.lastError.value == nil ? "You have no notification".localized() : "There is an error occurred".localized() + "\n" + "Tap to try again".localized()
        return NSMutableAttributedString()
            .gray(message)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        viewModel.reload()
    }
}
