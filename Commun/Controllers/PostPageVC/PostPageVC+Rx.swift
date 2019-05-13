//
//  PostPageVC+Rx.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxCocoa

extension PostPageVC: PostHeaderViewDelegate {
    
    func bindUI() {
        viewModel.post
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: {post in
                // Create tableHeaderView
                guard let headerView = UINib(nibName: "PostHeaderView", bundle: nil).instantiate(withOwner: self, options: nil).first as? PostHeaderView else {return}
                headerView.post = post
                headerView.delegate = self
            
                // Assign table header view
                self.tableView.tableHeaderView = headerView
            })
            .disposed(by: disposeBag)
    }
    
}
