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
    var contentInsets: UIEdgeInsets {.zero}
    
    // MARK: - Subviews
    lazy var tableView: UITableView = {
        let tableView = UITableView(backgroundColor: .clear)
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        tableView.separatorStyle = .none
        tableView.register(Cell.self, forCellReuseIdentifier: String(describing: Cell.self))
        return tableView
    }()
    
    init(originalItems: [T] = []) {
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
        tableView.autoPinEdgesToSuperviewEdges(with: contentInsets)
        
        dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(
            configureCell: { (_, _, indexPath, item) in
                self.configureCell(item: item, indexPath: indexPath)
            }
        )
    }
    
    override func bind() {
        super.bind()
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
    
    // MARK: - View model
    func remove(_ item: T) {
        var items = itemsRelay.value
        items.removeAll(where: {$0.identity == item.identity})
        itemsRelay.accept(items)
    }
    
    func update(_ item: T, with newItem: T) {
        if newItem == item {return}
        
        var items = self.itemsRelay.value
        if let index = items.firstIndex(where: {$0 == item}) {
            items[index] = item.newUpdatedItem(from: newItem)!
            items.removeDuplicates()
            self.itemsRelay.accept(items)
        }
    }
    
    func add(_ item: T) {
        var items = itemsRelay.value
        if items.contains(where: {$0.identity == item.identity}) {return}
        items.append(item)
        itemsRelay.accept(items)
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> T? {
        return itemsRelay.value[safe: indexPath.row]
    }
    
    func itemAtCell(_ cell: Cell) -> T? {
        guard let indexPath = tableView.indexPath(for: cell) else {return nil}
        return itemAtIndexPath(indexPath)
    }
}
