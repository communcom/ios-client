//
//  WalletVC.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class WalletVC: ListViewController<ResponseAPIWalletGetTransferHistoryItem, TransferHistoryItemCell> {
    // MARK: - Properties
    override var tableViewMargin: UIEdgeInsets {
        UIEdgeInsets(inset: 10)
    }
    
    init() {
        let fetcher = TransferHistoryListFetcher()
        let viewModel = TransferHistoryViewModel(fetcher: fetcher)
        super.init(viewModel: viewModel)
        
        defer {
            self.viewModel.fetchNext()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9591314197, green: 0.9661319852, blue: 0.9840201735, alpha: 1)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    override func bind() {
        super.bind()
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func configureCell(with item: ResponseAPIWalletGetTransferHistoryItem, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(with: item, indexPath: indexPath) as! TransferHistoryItemCell
        
        cell.roundedCorner = []
        
        if let lastSectionItemsCount = dataSource.sectionModels.last?.items.count,
            indexPath.section == dataSource.sectionModels.count - 1,
            indexPath.row == lastSectionItemsCount - 1
        {
            cell.roundedCorner.insert([.bottomLeft, .bottomRight])
        }
        
        return cell
    }
    
    override func bindItems() {
        viewModel.items
            .map { (items) -> [ListSection] in
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let dictionary = Dictionary(grouping: items) { item -> Int in
                    let date = Date.from(string: item.timestamp)
                    let createdDate = calendar.startOfDay(for: date)
                    return calendar.dateComponents([.day], from: createdDate, to: today).day ?? 0
                }
                
                return dictionary.keys.sorted()
                    .map { (key) -> ListSection in
                        var sectionLabel: String
                        switch key {
                        case 0:
                            sectionLabel = "today".localized().uppercaseFirst
                        case 1:
                            sectionLabel = "yesterday".localized().uppercaseFirst
                        default:
                            sectionLabel = "\(key) " + "days ago".localized()
                        }
                        return ListSection(model: sectionLabel, items: dictionary[key] ?? [])
                    }
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func handleListEmpty() {
        let title = "no transactions"
        let description = "you haven't had any transactions yet"
        tableView.addEmptyPlaceholderFooterView(emoji: "👁", title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
}

extension WalletVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        
        let label = UILabel.with(text: dataSource.sectionModels[section].model, textSize: 12, weight: .semibold)
        view.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        return view
    }
}
