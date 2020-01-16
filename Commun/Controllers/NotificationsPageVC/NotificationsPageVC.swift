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
    private lazy var smallTitleLabel = UILabel.with(text: title, textSize: 15, weight: .medium)
    private lazy var largeTitleLabel = UILabel.with(text: title, textSize: 30, weight: .bold)
    private lazy var newNotificationsCountLabel = UILabel.with(text: "new notifications", textSize: 12, weight: .regular, textColor: .a5a7bd)
    private var headerViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initializers
    init() {
        let vm = NotificationsPageViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func setUp() {
        super.setUp()
        title = "notifications".localized().uppercaseFirst
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset.top = headerViewMaxHeight
        
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
        newNotificationsCountLabel.autoPinEdge(.top, to: .bottom, of: largeTitleLabel)
        newNotificationsCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        newNotificationsCountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
    }
    
    override func bind() {
        super.bind()
        tableView.rx.contentOffset.map {$0.y}
            .subscribe(onNext: { (y) in
                if y >= -self.headerViewMinHeight {
                    self.headerViewHeightConstraint?.constant = self.headerViewMinHeight
                    self.largeTitleLabel.isHidden = true
                    self.newNotificationsCountLabel.isHidden = true
                    self.smallTitleLabel.isHidden = false
                } else if y <= -self.headerViewMaxHeight {
                    self.headerViewHeightConstraint?.constant = self.headerViewMaxHeight
                    self.largeTitleLabel.isHidden = false
                    self.newNotificationsCountLabel.isHidden = false
                    self.smallTitleLabel.isHidden = true
                } else {
                    self.headerViewHeightConstraint?.constant = abs(y)
                    self.largeTitleLabel.isHidden = false
                    self.newNotificationsCountLabel.isHidden = false
                    self.smallTitleLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
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
