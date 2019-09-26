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
        // feedTypeMode
        viewModel.feedTypeMode
            .bind { feedTypeMode in
                switch feedTypeMode {
                case .subscriptions:
                    self.headerLabel.text = "my Feed".localized().uppercaseFirst
                    self.changeFeedTypeButton.setTitle("trending".localized().uppercaseFirst, for: .normal)
                case .community:
                    self.headerLabel.text = "trending".localized().uppercaseFirst
                    
                    self.changeFeedTypeButton.setTitle("my Feed".localized().uppercaseFirst, for: .normal)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        // feedType
        viewModel.feedType
            .bind {feedType in
                self.sortByTypeButton.setTitle(feedType.toString(), for: .normal)
            }
            .disposed(by: disposeBag)
        
        // sortType
        viewModel.sortType
            .bind { (mode) in
                switch mode {
                case .all:
                    self.sortByTimeButton.backgroundColor = .white
                    break
                default:
                    self.sortByTimeButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                    break
                }
                self.sortByTimeButton.setTitle(mode.toString(), for: .normal)
            }
            .disposed(by: disposeBag)
        
        // items
        viewModel.items
            .map {[PostSection(model: "", items: $0)]}
            .do(onNext: {section in
                self.tableView.refreshControl?.endRefreshing()
            })
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
