//
//  PostsFilterVC.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class PostsFilterVC: SwipeDownDismissViewController {
    // MARK: - Properties
    var initFilter: PostsListFetcher.Filter
    var filter: BehaviorRelay<PostsListFetcher.Filter>
    let disposeBag = DisposeBag()
    var completion: ((PostsListFetcher.Filter) -> Void)?
    
    // MARK: - Subview
    lazy var closeButton = UIButton.circle(size: 30, backgroundColor: .f7f7f9, tintColor: .a5a7bd, imageName: "close-x", imageEdgeInsets: UIEdgeInsets(inset: 6))
    
    lazy var tableView = UITableView(forAutoLayout: ())
    lazy var saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst)
    
    // MARK: - Initializers
    init(filter: PostsListFetcher.Filter) {
        self.initFilter = filter
        self.filter = BehaviorRelay<PostsListFetcher.Filter>(value: filter)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    override func setUp() {
        super.setUp()
        view.backgroundColor = .f7f7f9
        
        title = "sort by".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonDidTouch), for: .touchUpInside)
        
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        view.addSubview(saveButton)
        saveButton.autoPinEdge(.top, to: .bottom, of: tableView, withOffset: 20)
        saveButton.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), excludingEdge: .top)
        
        
    }
    
    override func bind() {
        super.bind()
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        
        filter
            .map { (filter) -> [(label: String, isSelected: Bool)] in
                if self.initFilter.feedTypeMode != .topLikes {
                    return [
                        (label: "hot".localized().uppercaseFirst, isSelected: filter.feedTypeMode == .hot),
                        (label: "new".localized().uppercaseFirst, isSelected: filter.feedTypeMode == .new),
                        (label: "popular".localized().uppercaseFirst, isSelected: filter.feedTypeMode == .topLikes)
                    ]
                }
                
                return [
                    (label: "past 24 hours".localized().uppercaseFirst, isSelected: filter.sortType == .day),
                    (label: "past week".localized().uppercaseFirst, isSelected: filter.sortType == .week),
                    (label: "past month".localized().uppercaseFirst, isSelected: filter.sortType == .month),
                    (label: "all time".localized().uppercaseFirst, isSelected: filter.sortType == .all)
                ]
            }
            .bind(to: self.tableView.rx.items(cellIdentifier: "FilterCell", cellType: FilterCell.self)){ (index,model,cell) in
                cell.titleLabel.text = model.label
                cell.checkBox.isSelected = model.isSelected
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                if self.initFilter.feedTypeMode != .topLikes {
                    if indexPath.row == 0 {
                        self.filter.accept(self.filter.value.newFilter(withFeedTypeMode: .hot, feedType: .timeDesc))
                    }
                    if indexPath.row == 1 {
                        self.filter.accept(self.filter.value.newFilter(withFeedTypeMode: .new, feedType: .timeDesc))
                    }
                    if indexPath.row == 2 {
                        self.filter.accept(self.filter.value.newFilter(withFeedTypeMode: .topLikes))
                        let vc = PostsFilterVC(filter: self.filter.value.newFilter(sortType: self.filter.value.sortType ?? .all))
                        self.show(vc, sender: nil)
                    }
                }
                else {
                    if indexPath.row == 0 {
                        self.filter.accept(self.filter.value.newFilter(sortType: .day))
                    }
                    if indexPath.row == 1 {
                        self.filter.accept(self.filter.value.newFilter(sortType: .week))
                    }
                    if indexPath.row == 2 {
                        self.filter.accept(self.filter.value.newFilter(sortType: .month))
                    }
                    if indexPath.row == 3 {
                        self.filter.accept(self.filter.value.newFilter(sortType: .all))
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func closeButtonDidTouch() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PostsFilterVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}


