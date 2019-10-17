//
//  FeedPageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 29/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources
import CyberSwift

public typealias PostSection = AnimatableSectionModel<String, ResponseAPIContentGetPost>

extension FeedPageVC {
    func bindUI() {
        // filter
        viewModel.filter
            .subscribe(onNext: {filter in
                // feedTypeMode
                switch filter.feedTypeMode {
                case .subscriptions:
                    self.headerLabel.text = "my Feed".localized().uppercaseFirst
                    self.changeFeedTypeButton.setTitle("trending".localized().uppercaseFirst, for: .normal)
                case .new:
                    self.headerLabel.text = "trending".localized().uppercaseFirst
                    
                    self.changeFeedTypeButton.setTitle("my Feed".localized().uppercaseFirst, for: .normal)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // items
        viewModel.items
            .map {[PostSection(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ResponseAPIContentGetPost.self)
            .subscribe(onNext: {post in
                let postPageVC = controllerContainer.resolve(PostPageVC.self)!
                postPageVC.viewModel.postForRequest = post
                self.show(postPageVC, sender: nil)
            })
            .disposed(by: disposeBag)
    }
}
