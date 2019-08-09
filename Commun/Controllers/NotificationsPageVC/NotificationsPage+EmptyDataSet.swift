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
        let message = String(format: "%@!", (viewModel.fetcher.lastError == nil ? "no notification" : "error").localized().uppercaseFirst)
        return NSMutableAttributedString()
            .bold(message, font: .boldSystemFont(ofSize: 22))
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let message = (viewModel.fetcher.lastError == nil ? "you have no notification" : "there is an error occurred").localized().uppercaseFirst + "\n" + "tap to try again".localized().uppercaseFirst
        return NSMutableAttributedString()
            .gray(message)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        viewModel.reload()
    }
}
