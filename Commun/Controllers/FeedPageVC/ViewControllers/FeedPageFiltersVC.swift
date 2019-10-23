//
//  FeedPageFiltersVC.swift
//  Commun
//
//  Created by Chung Tran on 9/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift

class FeedPageFiltersVC: SwipeDownDismissViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var filter = BehaviorRelay<PostsListFetcher.Filter>(value: PostsListFetcher.Filter(feedTypeMode: .new, feedType: .popular, sortType: .all, searchKey: nil))
    var completion: ((PostsListFetcher.Filter) -> Void)?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactor = SwipeDownInteractor()
        
        view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.showsVerticalScrollIndicator = false
        
        bind()
    }
    
    func bind() {
        
        filter.skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: {_ in self.tableView.reloadData()})
            .disposed(by: disposeBag)
    }
    
    @IBAction func nextButtonDidTouch(_ sender: Any) {
        completion?(filter.value)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension FeedPageFiltersVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1
        {
            if filter.value.feedTypeMode == .new &&
                filter.value.feedType == .popular {
                return 5
            }
            return 0
        }
        
        if section == 0, filter.value.feedTypeMode != .new {
            return 2
        }
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedPageFilterCell", for: indexPath) as! FeedPageFilterCell
        switch indexPath.section {
        case 0:
            var feedSortMode: FeedSortMode!
            switch indexPath.row {
            case 0:
                if filter.value.feedTypeMode != .new {
                    feedSortMode = .timeDesc
                } else {
                    feedSortMode = .popular
                }
                
            case 1:
                if filter.value.feedTypeMode != .new {
                    feedSortMode = .time
                } else {
                    feedSortMode = .timeDesc
                }
            case 2:
                feedSortMode = .time
            default:
                return UITableViewCell()
            }
            cell.filterLabel.text = feedSortMode.toString()
            cell.checkBox.isSelected = (filter.value.feedType == feedSortMode)
        case 1:
            var timeFrameMode: FeedTimeFrameMode!
            switch indexPath.row {
            case 0:
                timeFrameMode = .all
            case 1:
                timeFrameMode = .day
            case 2:
                timeFrameMode = .week
            case 3:
                timeFrameMode = .month
            case 4:
                timeFrameMode = .year
            default:
                return UITableViewCell()
            }
            cell.filterLabel.text = timeFrameMode.toString()
            cell.checkBox.isSelected = (filter.value.sortType == timeFrameMode)
        default:
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if filter.value.feedTypeMode != .new {
                    filter.accept(filter.value.newFilter(feedType: .timeDesc))
                } else {
                    filter.accept(filter.value.newFilter(feedType: .popular))
                }
            case 1:
                if filter.value.feedTypeMode != .new {
                    filter.accept(filter.value.newFilter(feedType: .time))
                }
                else {
                    filter.accept(filter.value.newFilter(feedType: .timeDesc))
                }
            case 2:
                filter.accept(filter.value.newFilter(feedType: .time))
            default:
                return
            }
        case 1:
            switch indexPath.row {
            case 0:
                filter.accept(filter.value.newFilter(sortType: .all))
            case 1:
                filter.accept(filter.value.newFilter(sortType: .day))
            case 2:
                filter.accept(filter.value.newFilter(sortType: .week))
            case 3:
                filter.accept(filter.value.newFilter(sortType: .month))
            case 4:
                filter.accept(filter.value.newFilter(sortType: .year))
            default:
                return
            }
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
}

extension FeedPageFiltersVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor?.hasStarted == true ? interactor : nil
    }
}
