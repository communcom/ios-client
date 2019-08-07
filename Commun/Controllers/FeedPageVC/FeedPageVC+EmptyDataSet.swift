//
//  FeedPageVC+EmptyDataSet.swift
//  Commun
//
//  Created by Chung Tran on 03/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import DZNEmptyDataSet

extension FeedPageVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ProfilePageItemsEmptyPost")
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return dataSource.isEmpty
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let message = viewModel.fetcher.lastError == nil ? "No Posts".localized() : "Error".localized() + "!"
        return NSMutableAttributedString()
            .bold(message, font: .boldSystemFont(ofSize: 22))
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let message = viewModel.fetcher.lastError == nil ? "No post to show".localized() : "There is an error occurred".localized() + "\n" + "Tap to try again".localized()
        return NSMutableAttributedString()
            .gray(message)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        viewModel.reload()
    }
}
