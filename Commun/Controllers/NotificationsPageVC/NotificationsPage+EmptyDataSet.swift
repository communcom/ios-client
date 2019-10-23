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
        var message = "no notification"
        switch viewModel.fetcher.state.value {
        case .error(_):
            message = "error"
        default:
            break
        }
        message = message.localized().uppercaseFirst
        return NSMutableAttributedString()
            .bold(message, font: .boldSystemFont(ofSize: 22))
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var message = "you have no notification"
        switch viewModel.fetcher.state.value {
        case .error(_):
            message = "there is an error occurred"
        default:
            break
        }
        
        message = message.localized().uppercaseFirst + "\n" +
            "tap to try again".localized().uppercaseFirst
        
        return NSMutableAttributedString()
            .gray(message)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        viewModel.reload()
    }
}
