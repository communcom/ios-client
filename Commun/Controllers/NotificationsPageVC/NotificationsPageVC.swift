//
//  NotificationsPageVC.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NotificationsPageVC: ListViewController<ResponseAPIGetNotificationItem, NotificationCell> {
    // MARK: - Constants
    private let headerViewMaxHeight: CGFloat = 82
    private let headerViewMinHeight: CGFloat = 44
    
    // MARK: - Properties
    private lazy var headerView = UIView(backgroundColor: .white)
    private lazy var smallTitleLabel = UILabel.with(text: title, textSize: 15, weight: .semibold)
    private lazy var largeTitleLabel = UILabel.with(text: title, textSize: 30, weight: .bold)
    private lazy var newNotificationsCountLabel = UILabel.with(text: "", textSize: 12, weight: .regular, textColor: .a5a7bd)
    private var headerViewHeightConstraint: NSLayoutConstraint?
    private var headerViewHeight: CGFloat = 0
    
    // MARK: - Initializers
    init() {
        let vm = NotificationsPageViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.configureForAutoLayout()
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea()
        return tableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = headerView.height
        if headerViewHeight == 0 {
            tableView.contentInset.top = height
            headerViewHeight = height
            scrollToTop()
        }
    }
    
    override func viewWillSetUpTableView() {
        super.viewWillSetUpTableView()
        title = "notifications".localized().uppercaseFirst
        view.backgroundColor = .white
        
        // headerView
        headerView.clipsToBounds = true
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        headerViewHeightConstraint = headerView.autoSetDimension(.height, toSize: headerViewMaxHeight)
        
        headerView.addSubview(smallTitleLabel)
        smallTitleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        smallTitleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        
        headerView.addSubview(largeTitleLabel)
        largeTitleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        headerView.addSubview(newNotificationsCountLabel)
        newNotificationsCountLabel.autoPinEdge(.top, to: .bottom, of: largeTitleLabel, withOffset: -4)
        newNotificationsCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        newNotificationsCountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
        
        smallTitleLabel.isHidden = true
        headerView.addShadow(ofColor: .shadow, radius: 16, offset: CGSize(width: 0, height: 6), opacity: 0)
    }
    
    override func setUpTableView() {
        super.setUpTableView()
        tableView.backgroundColor = .f3f5fa
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
    }
    
    override func viewDidSetUpTableView() {
        super.viewDidSetUpTableView()
        view.bringSubviewToFront(headerView)
    }
    
    override func bind() {
        super.bind()
        tableView.rx.contentOffset.map {$0.y}
            .skip(2)
            .subscribe(onNext: { (y) in
                if y >= -self.headerViewMinHeight {
                    if self.headerViewHeightConstraint?.constant == self.headerViewMinHeight {return}
                    self.headerViewHeightConstraint?.constant = self.headerViewMinHeight
                    self.largeTitleLabel.isHidden = true
                    self.newNotificationsCountLabel.isHidden = true
                    self.smallTitleLabel.isHidden = false
                    self.headerView.shadowOpacity = 0.05
                } else if y <= -self.headerViewMaxHeight {
                    if self.headerViewHeightConstraint?.constant == self.headerViewMaxHeight {return}
                    self.headerViewHeightConstraint?.constant = self.headerViewMaxHeight
                    self.largeTitleLabel.isHidden = false
                    self.newNotificationsCountLabel.isHidden = false
                    self.smallTitleLabel.isHidden = true
                    self.headerView.shadowOpacity = 0
                } else {
                    if self.headerViewHeightConstraint?.constant == abs(y) {return}
                    self.headerViewHeightConstraint?.constant = abs(y)
                    self.largeTitleLabel.isHidden = false
                    self.newNotificationsCountLabel.isHidden = false
                    self.smallTitleLabel.isHidden = true
                    self.headerView.shadowOpacity = 0
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        viewModel.items
            .map {items in
                // TODO: - Restrict notification types, remove later
                items.filter {
                    $0.eventType == "subscribe" ||
                    $0.eventType == "reply" ||
                    $0.eventType == "mention" ||
                    $0.eventType == "upvote" ||
                    $0.eventType == "reward" ||
                    $0.eventType == "transfer"
                }
            }
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
        
        (viewModel as! NotificationsPageViewModel).unseenCount
            .subscribe(onNext: { (newCount) in
                let text = NSMutableAttributedString()
                if newCount > 0 {
                    text.text("•", size: 20, color: .appMainColor)
                        .normal(" ")
                        .text("\(newCount) new notifications".localized().uppercaseFirst, size: 12, color: .a5a7bd)
                }
                self.newNotificationsCountLabel.attributedText = text
            })
            .disposed(by: disposeBag)
    }
    
    override func modelSelected(_ item: ResponseAPIGetNotificationItem) {
        navigateWithNotificationItem(item)
        (viewModel as! NotificationsPageViewModel).markAsRead([item])
    }
    
    override func handleListEmpty() {
        let title = "no notification"
        let description = "you haven't had any notification yet"
        tableView.addEmptyPlaceholderFooterView(emoji: "🙈", title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
}

extension NotificationsPageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let headerView = UIView(frame: .zero)
        headerView.backgroundColor = .white
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges()
        
        let label = UILabel.with(text: dataSource.sectionModels[section].model, textSize: 12, weight: .semibold)
        headerView.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        return view
    }
    
    // https://stackoverflow.com/questions/1074006/is-it-possible-to-disable-floating-headers-in-uitableview-with-uitableviewstylep
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView(frame: .zero)
    }

}
