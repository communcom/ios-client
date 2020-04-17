//
//  ProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class ProfileVC<ProfileType: Decodable>: BaseViewController {
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.hidden}
    
    // MARK: - Constants
    let coverHeight: CGFloat = 200
    let coverVisibleHeight: CGFloat = 150
    var coverImageHeightConstraint: NSLayoutConstraint!
    var coverImageWidthConstraint: NSLayoutConstraint!
    let refreshControl = UIRefreshControl(forAutoLayout: ())
    
    // MARK: - Properties
    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    lazy var viewModel: ProfileViewModel<ProfileType> = self.createViewModel()
    var originInsetBottom: CGFloat?
    var frozenContentOffsetForRowAnimation: CGPoint?
    
    func createViewModel() -> ProfileViewModel<ProfileType> {
        fatalError("must override")
    }
    
    var showNavigationBar = false {
        didSet {
            configureNavigationBar()
        }
    }
    
    // MARK: - Subviews
    
    lazy var customNavigationBar = UIView(backgroundColor: .clear)
    lazy var backButton = UIButton.back(tintColor: .appWhiteColor, contentInsets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 15))
    lazy var titleLabel = UILabel.with(textSize: 17, weight: .bold, textColor: .clear, textAlignment: .center)
    lazy var optionsButton = UIButton.option(tintColor: .appWhiteColor)
    
    lazy var shadowView: UIView = {
        let view = UIView(forAutoLayout: ())
        view.backgroundColor = .clear
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: coverHeight)
        gradient.colors = [UIColor.appBlackColor.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 0.5]
        view.layer.insertSublayer(gradient, at: 0)
        return view
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholder
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var _headerView: ProfileHeaderView! {
        fatalError("Must override")
    }
    
    lazy var tableView: UITableView = setUpTableView()
    
    func setUpTableView() -> UITableView {
        let tableView = UITableView(forAutoLayout: ())
        tableView.backgroundColor = .clear
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        if originInsetBottom == nil && tableView.contentInset.bottom > 0 {
            originInsetBottom = tableView.contentInset.bottom
        }
    }

    override func setUp() {
        super.setUp()

        view.backgroundColor = #colorLiteral(red: 0.9605136514, green: 0.9644123912, blue: 0.9850376248, alpha: 1)
        view.addSubview(customNavigationBar)
        customNavigationBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let barContentView: UIView = {
            let view = UIView(forAutoLayout: ())
            view.addSubview(backButton)
            backButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
            view.addSubview(titleLabel)
            titleLabel.autoPinEdge(.leading, to: .trailing, of: backButton, withOffset: 10)
            titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
            view.addSubview(optionsButton)
            optionsButton.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 10)
            optionsButton.autoPinEdge(toSuperviewEdge: .trailing)
            optionsButton.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
            return view
        }()
        customNavigationBar.addSubview(barContentView)
        barContentView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(moreActionsButtonDidTouch(_:)), for: .touchUpInside)

        let screenWidth = UIScreen.main.bounds.size.width
        view.addSubview(coverImageView)
        coverImageView.autoPinEdge(toSuperviewEdge: .top)
        coverImageView.autoAlignAxis(.vertical, toSameAxisOf: view)
        
        coverImageWidthConstraint = coverImageView.widthAnchor.constraint(equalToConstant: screenWidth)
        coverImageWidthConstraint.isActive = true
        coverImageHeightConstraint = coverImageView.heightAnchor.constraint(equalToConstant: coverHeight)
        coverImageHeightConstraint.isActive = true

        view.addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges()

        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.contentInset.top = coverVisibleHeight

        // setup datasource
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
        
        tableView.separatorStyle = .none
        tableView.setContentOffset(CGPoint(x: 0, y: -coverHeight), animated: true)
        
        // pull to refresh

        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.tintColor = .appWhiteColor
        refreshControl.subviews.first?.bounds.origin.y = 112
        
        _headerView.segmentedControl.delegate = self
        
        view.bringSubviewToFront(customNavigationBar)
    }

    @objc func refresh() {
        self.reload()
        refreshControl.endRefreshing()
    }

    override func bind() {
        super.bind()
        bindControls()
        
        bindProfile()
        
        bindList()
    }
    
    func bindProfile() {
        viewModel.profile
            .filter {$0 != nil}
            .map {$0!}
            .do(onNext: { (_) in
                self._headerView.selectedIndex.accept(self._headerView.selectedIndex.value)
            })
            .subscribe(onNext: { [weak self] (item) in
                self?.setUp(profile: item)
            })
            .disposed(by: disposeBag)
    }
    
    func setUp(profile: ProfileType) {
    }
    
    func handleListLoading() {
        
    }
    
    func handleListEnded() {
        
    }
    
    func handleListEmpty() {
        
    }
    
    func bindItems() {
        
    }
    
    func cellSelected(_ indexPath: IndexPath) {
        
    }
    
    @objc func didTapTryAgain(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text else {return}
        
        let tryAgainRange = (text as NSString).range(of: "try again".localized().uppercaseFirst)
        if gesture.didTapAttributedTextInLabel(label: label, inRange: tryAgainRange) {
            viewModel.fetchNext(forceRetry: true)
        }
    }
    
    @objc func moreActionsButtonDidTouch(_ sender: CommunButton) {
        // for overriding
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        
        changeStatusBarStyle(showNavigationBar ? .default : .lightContent)
        
        coverImageView.isHidden = showNavigationBar
        
        customNavigationBar.backgroundColor = showNavigationBar ? .appWhiteColor : .clear
        customNavigationBar.addShadow(ofColor: .shadow, radius: showNavigationBar ? CGFloat.adaptive(width: 16.0) : 0, offset: CGSize(width: 0.0, height: showNavigationBar ? CGFloat.adaptive(height: 6.0) : 0), opacity: showNavigationBar ? 0.05 : 0)
        backButton.tintColor = showNavigationBar ? .appBlackColor: .appWhiteColor
        titleLabel.textColor = showNavigationBar ? .appBlackColor: .clear
        optionsButton.tintColor = showNavigationBar ? .appBlackColor: .appWhiteColor
        
        if showNavigationBar {
            optionsButton.layer.shadowOpacity = 0
        } else {
            optionsButton.layer.shadowRadius = 2
            optionsButton.layer.shadowColor = UIColor.appBlackColor.cgColor
            optionsButton.layer.shadowOffset = CGSize(width: 0, height: 1)
            optionsButton.layer.shadowOpacity = 0.25
            optionsButton.layer.masksToBounds = false
        }
    }

    @objc func reload() {
        viewModel.reload()
    }
}

// MARK: - CMSegmentedControlDelegate
extension ProfileVC: CMSegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: CMSegmentedControl, didTapOptionAtIndex: Int) {
        // Add additional space to bottom of tableView to prevent jumping lag when swich tab
        let headerMaxY = _headerView.convert(_headerView.bounds, to: view).maxY
        
        let newInsetBottom: CGFloat = UIScreen.main.bounds.height - headerMaxY
        tableView.contentInset.bottom = newInsetBottom
        
        frozenContentOffsetForRowAnimation = tableView.contentOffset
        // Return contentInset to original value after updating
        tableView.rx.endUpdatesEvent
            .debounce(1, scheduler: MainScheduler.instance)
            .take(1)
            .asSingle()
            .subscribe(onSuccess: {[weak self] (_) in
                guard let strongSelf = self else {return}
                if let inset = strongSelf.originInsetBottom,
                    (UIScreen.main.bounds.height - strongSelf.tableView.contentSize.height + strongSelf.tableView.contentOffset.y < inset)
                {
                    strongSelf.tableView.contentInset.bottom = inset
                }
            })
            .disposed(by: disposeBag)
    }
}
