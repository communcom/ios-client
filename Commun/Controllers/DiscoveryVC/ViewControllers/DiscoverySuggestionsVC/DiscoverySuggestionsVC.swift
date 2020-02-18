//
//  DiscoverySuggestionsVC.swift
//  Commun
//
//  Created by Chung Tran on 2/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DiscoverySuggestionsVC: ListViewController<ResponseAPIContentSearchItem, DiscoverySuggestionCell> {
    // MARK: - Properties
    var showAllHandler: (() -> Void)?
    
    // MARK: - Initializers
    init(showAllHandler: (() -> Void)? = nil) {
        let vm = SearchViewModel()
        (vm.fetcher as! SearchListFetcher).searchType = .quickSearch
        (vm.fetcher as! SearchListFetcher).entities = [.profiles, .communities]
        self.showAllHandler = showAllHandler
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        tableView.backgroundColor = .f3f5fa
        tableView.separatorStyle = .none
    }
    
    override func bind() {
        super.bind()
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func modelSelected(_ item: ResponseAPIContentSearchItem) {
        if let community = item.communityValue {
            showCommunityWithCommunityId(community.communityId)
            return
        }
        
        if let user = item.profileValue {
            showProfileWithUserId(user.userId)
            return
        }
    }
    
    override func handleListEmpty() {}
    
    override func handleLoading() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

        tableView.tableFooterView = spinner
    }
    
    override func search(_ keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            viewModel.fetcher.search = nil
            viewModel.state.accept(.loading(false))
            viewModel.items.accept([])
            return
        }
        
        if viewModel.fetcher.search != keyword {
            viewModel.fetcher.search = keyword
            viewModel.reload(clearResult: false)
        }
    }
    
    // MARK: - Actions
    @objc func showAllResultDidTouch() {
        showAllHandler?()
    }
}

extension DiscoverySuggestionsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .f3f5fa
        
        let headerView = UIView(backgroundColor: .white)
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
        
        let label = UILabel.with(text: "show all results".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .appMainColor)
        headerView.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAllResultDidTouch)))
        return view
    }
}
