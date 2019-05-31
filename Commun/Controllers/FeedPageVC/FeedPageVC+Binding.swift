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
        // scrollview
        self.tableView.rx.willEndDragging
            .map {$0.velocity.y > 0 ? 0: 50}
            .subscribe(onNext: {height in
                UIView.animate(withDuration: 0.25, animations: {
                    self.searchBarHeightConstraint.constant = CGFloat(height)
                    self.view.layoutIfNeeded()
                })
            })
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
        let dataSource = RxTableViewSectionedAnimatedDataSource<PostSection>(
            configureCell: { dataSource, tableView, indexPath, item in
                if item.contentId.permlink == "___mock___" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderPostCell", for: indexPath) as! PlaceholderPostCell
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostCardCell", for: indexPath) as! PostCardCell
                cell.setUp(with: item)
                
                if indexPath.row == self.viewModel.items.value.count - 2 {
                    self.viewModel.fetchNext()
                }
                
                return cell
            }
        )
        
        viewModel.items
            .map {[PostSection(model: "", items: $0.count>0 ? $0: [ResponseAPIContentGetPost.mockData()!])]}
            .do(onNext: {section in
                section[0].items.count > 0 ? self.view.hideLoading(): self.view.showLoading()
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
