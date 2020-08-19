//
//  PostsFilterVC.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class PostsFilterVC: BaseViewController {
    // MARK: - Properties
    var isTimeFrameMode: Bool
    var isTrending: Bool
    var filter: BehaviorRelay<PostsListFetcher.Filter>
    var completion: ((PostsListFetcher.Filter) -> Void)?
    
    // MARK: - Subview
    lazy var languageView: MyTableHeaderView = {
        let view = MyTableHeaderView(tableView: tableView)
        let whiteView = UIView(height: 58, backgroundColor: .appWhiteColor, cornerRadius: 10)
        view.addSubview(whiteView)
        whiteView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        
        let label = UILabel.with(text: "language".localized().uppercaseFirst, textSize: 15, weight: .semibold)
        whiteView.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)

        let languageLabel = UILabel.with(textSize: 15, weight: .semibold, textColor: .appGrayColor)
        whiteView.addSubview(languageLabel)
        languageLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        PostsListFetcher.Filter.Language.observable
            .map {$0.localizedName.uppercaseFirst}
            .asDriver(onErrorJustReturn: "")
            .drive(languageLabel.rx.text)
            .disposed(by: disposeBag)

        let arrow = UIImageView(width: 12, height: 6, imageNamed: "drop-down")
        whiteView.addSubview(arrow)

        languageLabel.autoPinEdge(.trailing, to: .leading, of: arrow, withOffset: -10)
        arrow.autoAlignAxis(toSuperviewAxis: .horizontal)
        arrow.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        return view
    }()
    lazy var closeButton = UIButton.close(size: 30.0)
    lazy var backButton = UIButton.circle(size: 30.0, backgroundColor: .appLightGrayColor, tintColor: .appGrayColor, imageName: "back-button", imageEdgeInsets: UIEdgeInsets(inset: 6))
    
    lazy var tableView = UITableView(forAutoLayout: ())
    lazy var saveButton = CommunButton.default(height: 50, label: "save".localized().uppercaseFirst)
    
    // MARK: - Initializers
    init(filter: PostsListFetcher.Filter, isTimeFrameMode: Bool = false) {
        self.isTimeFrameMode = isTimeFrameMode
        self.isTrending = (filter.type == .hot || filter.type == .topLikes || filter.type == .new || filter.type == .community)
        self.filter = BehaviorRelay<PostsListFetcher.Filter>(value: filter)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    override func setUp() {
        super.setUp()
        
        view.backgroundColor = .appLightGrayColor
        title = "sort by".localized().uppercaseFirst

        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonDidTouch), for: .touchUpInside)
        
        if isTimeFrameMode {
            setLeftNavBarButton(with: backButton)
            backButton.addTarget(self, action: #selector(backButtonDidTouch), for: .touchUpInside)
        }
        
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        // language
        if !isTimeFrameMode {
            languageView.isUserInteractionEnabled = true
            languageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(languageViewDidTouch)))
        }
        
        view.addSubview(saveButton)
        saveButton.autoPinEdge(.top, to: .bottom, of: tableView, withOffset: 20)
        saveButton.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), excludingEdge: .top)
        saveButton.addTarget(self, action: #selector(saveButtonDidTouch), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        navigationController?.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20.0)
        navigationController?.navigationBar.frame.size.height = 58.0
    }
    
    override func bind() {
        super.bind()
        
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        
        filter
            .map { (filter) -> [(label: String, isSelected: Bool)] in
                if !self.isTimeFrameMode {
                    return [
                        (label: FeedTypeMode.hot.localizedLabel!.uppercaseFirst, isSelected: (filter.type == .hot || filter.type == .subscriptionsHot)),
                        (label: FeedTypeMode.new.localizedLabel!.uppercaseFirst, isSelected: (filter.type == .new || filter.type == .subscriptions)),
                        (label: FeedTypeMode.topLikes.localizedLabel!.uppercaseFirst, isSelected: (filter.type == .topLikes || filter.type == .subscriptionsPopular))
                    ]
                }
                
                return [
                    (label: FeedTimeFrameMode.day.localizedLabel.uppercaseFirst, isSelected: filter.timeframe == .day),
                    (label: FeedTimeFrameMode.week.localizedLabel.uppercaseFirst, isSelected: filter.timeframe == .week),
                    (label: FeedTimeFrameMode.month.localizedLabel.uppercaseFirst, isSelected: filter.timeframe == .month),
                    (label: FeedTimeFrameMode.all.localizedLabel.uppercaseFirst, isSelected: filter.timeframe == .all)
                ]
            }
            .bind(to: self.tableView.rx.items(cellIdentifier: "FilterCell", cellType: FilterCell.self)) { (index, model, cell) in
                var roundedCorner: UIRectCorner = []
                
                if index == 0 {
                    roundedCorner.insert([.topLeft, .topRight])
                }
                
                if index == (self.isTimeFrameMode ? 3 : 2) {
                    roundedCorner.insert([.bottomLeft, .bottomRight])
                }
                cell.roundedCorner = roundedCorner
                
                cell.titleLabel.text = model.label
                cell.checkBox.isSelected = model.isSelected
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                if !self.isTimeFrameMode {
                    let hotType: FeedTypeMode = self.isTrending ? .hot: .subscriptionsHot
                    let newType: FeedTypeMode = self.isTrending ? .new: .subscriptions
                    let popularType: FeedTypeMode = self.isTrending ? .topLikes: .subscriptionsPopular
                    if indexPath.row == 0 {
                        self.filter.accept(self.filter.value.newFilter(type: hotType, sortBy: .time))
                    }
                    if indexPath.row == 1 {
                        self.filter.accept(self.filter.value.newFilter(type: newType, sortBy: .time))
                    }
                    if indexPath.row == 2 {
                        self.filter.accept(self.filter.value.newFilter(type: popularType))
                        let vc = PostsFilterVC(filter: self.filter.value.newFilter(timeframe: self.filter.value.timeframe ?? .all), isTimeFrameMode: true)
                        vc.completion = self.completion
                        self.show(vc, sender: nil)
                    }
                } else {
                    if indexPath.row == 0 {
                        self.filter.accept(self.filter.value.newFilter(timeframe: .day))
                    }
                    if indexPath.row == 1 {
                        self.filter.accept(self.filter.value.newFilter(timeframe: .week))
                    }
                    if indexPath.row == 2 {
                        self.filter.accept(self.filter.value.newFilter(timeframe: .month))
                    }
                    if indexPath.row == 3 {
                        self.filter.accept(self.filter.value.newFilter(timeframe: .all))
                    }
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc func closeButtonDidTouch() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonDidTouch() {
        self.dismiss(animated: true) {
            self.completion?(self.filter.value)
        }
    }
    
    @objc func backButtonDidTouch() {
        navigationController?.popViewController()
    }
    
    @objc func languageViewDidTouch() {
        self.dismiss(animated: true) {
            let actions: [CMActionSheet.Action] = PostsListFetcher.Filter.Language.allCases.map({ language -> CMActionSheet.Action in
                
                CMActionSheet.Action.customLayout(height: 50, title: language.localizedName.uppercaseFirst, showIcon: false) {
                    UserDefaults.standard.set(language.rawValue, forKey: Config.currentUserFeedLanguage)
                }
                
            })
            UIApplication.topViewController()?.showCMActionSheet(actions: actions)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension PostsFilterVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomHeightPresentationController(height: 443.0, presentedViewController: presented, presenting: presenting)
    }
}

// MARK: - UITableViewDelegate
extension PostsFilterVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0
    }
}
