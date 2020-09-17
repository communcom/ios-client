//
//  CMTableViewController.swift
//  Commun
//
//  Created by Chung Tran on 9/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources

class CMTableViewController<T: ListItemType, Cell: UITableViewCell>: BaseViewController {
    typealias SectionModel = AnimatableSectionModel<String, T>
    let originalItems: [T]
    lazy var itemsRelay = BehaviorRelay<[T]>(value: originalItems)
    var dataSource: RxTableViewSectionedAnimatedDataSource<SectionModel>!
    
    // MARK: - Subviews
    lazy var tableView: UITableView = {
        let tableView = UITableView(backgroundColor: .clear)
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        tableView.separatorStyle = .none
        tableView.register(Cell.self, forCellReuseIdentifier: String(describing: Cell.self))
        return tableView
    }()
    
    init(originalItems: [T]) {
        self.originalItems = originalItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
    }
    
    override func bind() {
        super.bind()
        dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(
            configureCell: { (_, _, indexPath, item) in
                self.configureCell(item: item, indexPath: indexPath)
            }
        )
        
        itemsRelay.asDriver()
            .map {self.mapItemsToSections($0)}
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func mapItemsToSections(_ items: [T]) -> [SectionModel] {
        [SectionModel(model: "", items: items)]
    }
    
    func configureCell(item: T, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: Cell.self)) as! Cell
        return cell
    }
}
