//
//  DiscoverySuggestionsVC.swift
//  Commun
//
//  Created by Chung Tran on 2/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

class DiscoverySuggestionsVC: ListViewController<ResponseAPIContentSearchItem, DiscoverySuggestionCell> {
    // MARK: - Properties
    var showAllHandler: (() -> Void)?
    var cancelSearchHandler: (() -> Void)?
    
    // MARK: - Initializers
    init(showAllHandler: (() -> Void)? = nil, cancelSearchHandler: (() -> Void)? = nil) {
        let vm = SearchViewModel()
        (vm.fetcher as! SearchListFetcher).searchType = .quickSearch
        (vm.fetcher as! SearchListFetcher).entities = [.profiles, .communities]
        self.showAllHandler = showAllHandler
        self.cancelSearchHandler = cancelSearchHandler
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUpTableView() {
        super.setUpTableView()
        tableView.backgroundColor = .appLightGrayColor
        tableView.separatorStyle = .none
        
        tableView.keyboardDismissMode = .onDrag
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(gesture:)))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: tableView)
        
        // cancel search if tap outside cell
        if tableView.indexPathForRow(at: point) == nil {
            cancelSearchHandler?()
        }
        
    }
    
    override func bind() {
        super.bind()
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func mapItems(items: [ResponseAPIContentSearchItem]) -> [AnimatableSectionModel<String, ResponseAPIContentSearchItem>] {
        [ListSection(model: "", items: items)]
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
    
    override func handleListEmpty() {
        self.tableView.tableFooterView = nil
    }
    
    override func handleLoading() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

        tableView.tableFooterView = spinner
    }
    
    func searchBarIsSearchingWithQuery(_ query: String) {
        (viewModel as! SearchViewModel).query = query
        viewModel.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        viewModel.state.accept(.loading(false))
        viewModel.items.accept([])
    }
    
    // MARK: - Actions
    @objc func showAllResultDidTouch() {
        showAllHandler?()
    }
}

extension DiscoverySuggestionsVC: UITableViewDelegate {
    @objc func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (viewModel as! SearchViewModel).isQueryEmpty ? 0 : 51
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .appLightGrayColor
        
        let headerView = UIView(backgroundColor: .appWhiteColor)
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
        
        let label = UILabel.with(text: "show all results".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .appMainColor)
        headerView.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAllResultDidTouch)))
        return view
    }
}
