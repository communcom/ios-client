//
//  DiscoveryAllVC.swift
//  Commun
//
//  Created by Chung Tran on 2/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DiscoveryAllVC: SubsViewController<ResponseAPIContentSearchItem, SubscribersCell>, CommunityCellDelegate, ProfileCellDelegate {
    // MARK: - Properties
    
    // MARK: - Initializers
    init() {
        let vm = SearchViewModel()
        (vm.fetcher as! SearchListFetcher).searchType = .quickSearch
        (vm.fetcher as! SearchListFetcher).entities = [.profiles, .communities]
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func setUpTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.configureForAutoLayout()
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset.top -= 24
    }
    
    override func bind() {
        super.bind()
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        viewModel.items
            .map {items -> [ListSection] in
                let communities = items.filter {$0.communityValue != nil}
                let followers = items.filter {$0.profileValue != nil}
                var sections = [ListSection]()
                if !communities.isEmpty {
                    sections.append(ListSection(model: "communities".localized().uppercaseFirst, items: communities))
                }
                if !followers.isEmpty {
                    sections.append(ListSection(model: "followers".localized().uppercaseFirst, items: followers))
                }
                return sections
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func registerCell() {
        super.registerCell()
        tableView.register(CommunityCell.self, forCellReuseIdentifier: "CommunityCell")
    }
    
    override func configureCell(with item: ResponseAPIContentSearchItem, indexPath: IndexPath) -> UITableViewCell {
        if let community = item.communityValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityCell") as! CommunityCell
            cell.setUp(with: community)
            cell.delegate = self

            cell.roundedCorner = []

            if indexPath.row == self.viewModel.items.value.count - 1 {
                cell.roundedCorner.insert([.bottomLeft, .bottomRight])
            }
            return cell
        }
        
        if let user = item.profileValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "\(SubscribersCell.self)") as! SubscribersCell
            cell.setUp(with: user)
            cell.delegate = self
            
            cell.roundedCorner = []

            if indexPath.row == self.viewModel.items.value.count - 1 {
                cell.roundedCorner.insert([.bottomLeft, .bottomRight])
            }
            return cell
        }

        return UITableViewCell()
    }
    
    override func handleListEmpty() {
        let title = "no result".localized().uppercaseFirst
        let description = "try to look for something else".localized().uppercaseFirst
        tableView.addEmptyPlaceholderFooterView(emoji: "😿", title: title, description: description)
    }
    
    override func search(_ keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            viewModel.state.accept(.loading(false))
            viewModel.items.accept([])
            return
        }
        
        if self.viewModel.fetcher.search != keyword {
            self.viewModel.fetcher.search = keyword
            self.viewModel.reload(clearResult: false)
        }
    }
}

extension DiscoveryAllVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let headerView = UIView(backgroundColor: .white)
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges()
        
        let label = UILabel.with(text: dataSource.sectionModels[section].model, textSize: 15, weight: .semibold)
        headerView.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        DispatchQueue.main.async {
            headerView.roundCorners([.topLeft, .topRight], radius: 10)
        }
        return view
    }
}
