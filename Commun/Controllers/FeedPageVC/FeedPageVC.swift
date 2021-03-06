//
//  FeedPageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class FeedPageVC: PostsViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {.lightContent}
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.hidden}
    
    // MARK: - Properties
    lazy var floatView = FeedPageFloatView(forAutoLayout: ())
    var floatViewTopConstraint: NSLayoutConstraint!
    var headerView: FeedPageHeaderView!
    var floatViewHeight: CGFloat = 0
    var lastContentOffset: CGFloat = 0
    
    // MARK: - Initializers
    init() {
        let viewModel = FeedPageViewModel(prefetch: true)
        super.init(viewModel: viewModel)
    }
    
    override init(viewModel: PostsViewModel) {
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = floatView.height
        
        if floatViewHeight == 0 {
            tableView.contentInset.top = height
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: height, left: 0.0, bottom: 0.0, right: 0.0)
            floatViewHeight = height
            scrollToTop()
        }
    }
    
    override func setUp() {
        super.setUp()
       
        view.backgroundColor = .appLightGrayColor
        
        // tableView
        tableView.backgroundColor = .appLightGrayColor
        tableView.keyboardDismissMode = .onDrag
        
        let statusBarView = UIView(backgroundColor: .appMainColorDarkBlack)
        view.addSubview(statusBarView)
        statusBarView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        statusBarView.autoPinEdge(.bottom, to: .top, of: tableView)
        view.addSubview(floatView)
        floatViewTopConstraint = floatView.autoPinEdge(toSuperviewSafeArea: .top)
        floatView.autoPinEdge(toSuperviewSafeArea: .leading)
        floatView.autoPinEdge(toSuperviewSafeArea: .trailing)
        
        statusBarView.autoPinEdge(.bottom, to: .top, of: floatView)
        view.bringSubviewToFront(statusBarView)
        
        headerView = FeedPageHeaderView(tableView: tableView)
        headerView.delegate = self
        
        floatView.changeFeedTypeButton.addTarget(self, action: #selector(changeFeedTypeButtonDidTouch(_:)), for: .touchUpInside)
        floatView.sortButton.addTarget(self, action: #selector(changeFilterButtonDidTouch(_:)), for: .touchUpInside)
        headerView.getButton.addTarget(self, action: #selector(promoGetButtonDidTouch), for: .touchUpInside)
        
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: dataSource.animationConfiguration.insertAnimation, reloadAnimation: dataSource.animationConfiguration.reloadAnimation, deleteAnimation: .bottom)
    }
    
    override func bind() {
        super.bind()

        tableView.rx.willBeginDragging.subscribe { _ in
            self.lastContentOffset = self.tableView.contentOffset.y
        }.disposed(by: disposeBag)

           tableView.rx.contentOffset.observeOn(MainScheduler.asyncInstance)
            .subscribe {
            guard let offset = $0.element else { return }

            var needAnimation = false
            var newConstraint: CGFloat = 0.0
            let lastOffset: CGFloat = self.lastContentOffset
            let indent: CGFloat = 100

            if lastOffset > offset.y + indent || offset.y <= 0  {
                needAnimation = self.floatViewTopConstraint.constant <= 0
                newConstraint = 0.0
            } else if lastOffset < offset.y - indent {
                let position = -self.floatView.frame.size.height
                needAnimation = self.floatViewTopConstraint.constant >= position
                newConstraint = position
            }

            if needAnimation {
                self.view.layoutIfNeeded()
                self.floatViewTopConstraint.constant = newConstraint
                UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                })
            }
        }.disposed(by: disposeBag)
        
        // promo
        (viewModel as? FeedPageViewModel)?.claimedPromos
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { (_) in
//                if !claimedPromos.contains("DANK") {
//                    self.headerView.showPromoBanner()
//                }
            })
            .disposed(by: disposeBag)
    }
    
    override func modifyFilter(filter: PostsListFetcher.Filter) -> PostsListFetcher.Filter {
        var filter = filter
        switch filter.type {
        case .new, .subscriptions:
            filter.timeframe = nil
            if filter.sortBy == nil {
                filter.sortBy = .time
            }
        case .hot, .subscriptionsHot:
            filter.timeframe = nil
            filter.sortBy = nil
        case .topLikes, .subscriptionsPopular:
            filter.sortBy = nil
            if filter.timeframe == nil {
                filter.timeframe = .day
            }
        default:
            break
        }
        return filter
    }
    
    override func filterChanged(filter: PostsListFetcher.Filter) {
        super.filterChanged(filter: filter)
        floatView.setUp(with: filter)
        saveFilter(filter: filter)
    }
    
    func saveFilter(filter: PostsListFetcher.Filter) {
        // save filter
        do {
            try filter.save()
        } catch {
            print(error)
        }
    }
    
    func openEditor(completion: ((BasicEditorVC) -> Void)? = nil) {
        let editorVC = BasicEditorVC(chooseCommunityAfterLoading: completion == nil)
        
        present(editorVC, animated: true, completion: {
            completion?(editorVC)
        })
    }
    
    // MARK: - Actions
    @objc func promoGetButtonDidTouch() {
//        AnalyticsManger.shared.clickGetDankMeme()
//        headerView.getButton.showLoading(cover: true, coverColor: .appMainColor, spinnerColor: .appWhiteColor, size: 20)
//        RestAPIManager.instance.getAirdrop(communityId: "DANK")
//            .subscribe(onSuccess: { (_) in
//                self.headerView.getButton.hideLoading()
//                self.headerView.hidePromoBanner()
//                UIView.animate(withDuration: 0.3) {
//                    self.headerView.layoutIfNeeded()
//                }
//                self.showDone("done".localized().uppercaseFirst + "!")
//            }) { (error) in
//                self.headerView.getButton.hideLoading()
//                self.showError(error)
//            }
//            .disposed(by: disposeBag)
    }
    
    @objc func changeFeedTypeButtonDidTouch(_ sender: Any) {
        guard let viewModel = viewModel as? PostsViewModel else {return}
        switch viewModel.filter.value.type {
        case .subscriptions, .subscriptionsPopular, .subscriptionsHot:
            viewModel.filter.accept(PostsListFetcher.Filter(type: .topLikes, timeframe: .day, userId: Config.currentUser?.id))
        default:
            viewModel.filter.accept(PostsListFetcher.Filter(type: .subscriptions, sortBy: .time))
        }
    }
    
    @objc func changeFilterButtonDidTouch(_ sender: Any) {
        openFilterVC()
    }
}

extension FeedPageVC: FeedPageHeaderViewDelegate {
    func feedPageHeaderViewDidTouchWhatsNew(_ headerView: FeedPageHeaderView) {
        openEditor()
    }
    
    func feedPageHeaderViewDidTouchImageButton(_ headerView: FeedPageHeaderView) {
        openEditor { (editorVC) in
            editorVC.addImage()
        }
    }
}
