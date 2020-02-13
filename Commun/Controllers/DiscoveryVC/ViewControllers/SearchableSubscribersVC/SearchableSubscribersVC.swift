//
//  SearchableSubscribersVC.swift
//  Commun
//
//  Created by Chung Tran on 2/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SearchableSubscribersVC: SubscribersVC {
    // MARK: - Properties
    override var isSearchEnabled: Bool {true}
    
    // MARK: - Search manager
    override func search(_ keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            if self.viewModel.fetcher.search != nil {
                self.viewModel.fetcher.search = nil
                self.viewModel.reload()
            }
            return
        }
        
        if self.viewModel.fetcher.search != keyword {
            self.viewModel.fetcher.search = keyword.uppercaseFirst
            self.viewModel.reload(clearResult: false)
        }
    }
}
