//
//  ListViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class ListViewController<T: Decodable & Equatable & IdentifiableType>: BaseViewController {
    public typealias ListSection = AnimatableSectionModel<String, T>
    
    var disposeBag = DisposeBag()
    var viewModel: ListViewModel<T>!
    var dataSource: MyRxTableViewSectionedAnimatedDataSource<ListSection>!
    
    lazy var tableView: UITableView! = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avoidTabBar()
    }
    
    override func setUp() {
        super.setUp()
        // pull to refresh
        tableView.es.addPullToRefresh { [unowned self] in
            self.tableView.es.stopPullToRefresh()
            self.refresh()
        }
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func bind() {
        super.bind()
        viewModel.items
            .map {[ListSection(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.listEnded
            .subscribe(onNext: {[weak self] _ in
                self?.tableView.tableFooterView = UIView()
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: {[weak self] error in
                guard let strongSelf = self else {return}
                strongSelf.tableView.addListErrorFooterView(with: #selector(strongSelf.didTapTryAgain(gesture:)), on: strongSelf)
                strongSelf.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func avoidTabBar() {
        // avoid tabBar
        var contentInsets = tableView.contentInset
        contentInsets.bottom = tabBarController!.tabBar.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        
        tableView.contentInset = contentInsets
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
    
    @objc func didTapTryAgain(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text else {return}
        
        let tryAgainRange = (text as NSString).range(of: "try again".localized().uppercaseFirst)
        if gesture.didTapAttributedTextInLabel(label: label, inRange: tryAgainRange) {
            self.viewModel.fetchNext()
        }
    }
}
