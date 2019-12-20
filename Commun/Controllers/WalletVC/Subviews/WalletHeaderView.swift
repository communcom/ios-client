//
//  WalletHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 12/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CircularCarousel

class WalletHeaderView: MyTableHeaderView {
    // MARK: - Properties
    var maxItemsInCarousel = 5
    var stackViewTopConstraint: NSLayoutConstraint?
    var sendPointsTopConstraint: NSLayoutConstraint?
    var balances: [ResponseAPIWalletGetBalance]?
    var currentIndex: Int = 0 {
        didSet {
            if currentIndex == 0 {
                setUpWithCommunValue()
            } else {
                setUpWithCurrentBalance()
            }
        }
    }
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
    lazy var shadowView = UIView(forAutoLayout: ())
    lazy var contentView = UIView(backgroundColor: .appMainColor)
    
    lazy var carousel = CircularCarousel(height: 44)
    lazy var titleLabel = UILabel.with(text: "Equity Value Commun", textSize: 15, weight: .semibold, textColor: .white)
    lazy var pointLabel = UILabel.with(text: "167 500.23", textSize: 30, weight: .bold, textColor: .white, textAlignment: .center)
    
    // MARK: - Balance
    lazy var balanceContainerView = UIView(forAutoLayout: ())
    lazy var communValueLabel = UILabel.with(text: "= 150 Commun", textSize: 12, weight: .semibold, textColor: .white)
    lazy var progressView = UIProgressView(forAutoLayout: ())
    lazy var availableHoldValueLabel = UILabel.with(text: "available".localized().uppercaseFirst + "/" + "hold".localized().uppercaseFirst, textSize: 12, textColor: .white)
    
    // MARK: - Buttons
    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal)
        stackView.addBackground(color: UIColor.white.withAlphaComponent(0.1), cornerRadius: 16)
        stackView.cornerRadius = 16
        return stackView
    }()
    
    lazy var sendButton = UIButton.circle(size: 30, backgroundColor: UIColor.white.withAlphaComponent(0.2), tintColor: .white, imageName: "upVote", imageEdgeInsets: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
    
    lazy var convertButton = UIButton.circle(size: 30, backgroundColor: UIColor.white.withAlphaComponent(0.2), tintColor: .white, imageName: "convert", imageEdgeInsets: UIEdgeInsets(inset: 6))
    
    // MARK: - My points
    lazy var myPointsContainerView = UIView(forAutoLayout: ())
    
    lazy var myPointsCollectionView: UICollectionView = {
        let collectionView = UICollectionView.horizontalFlow(
            cellType: MyPointCollectionCell.self,
            height: MyPointCollectionCell.height,
            contentInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        )
        collectionView.layer.masksToBounds = false
        return collectionView
    }()
    
    // MARK: - Send points
    lazy var sendPointsContainerView = UIView(forAutoLayout: ())
    
    lazy var sendPointsCollectionView: UICollectionView = {
        let collectionView = UICollectionView.horizontalFlow(
            cellType: SendPointCollectionCell.self,
            height: SendPointCollectionCell.height,
            contentInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        )
        collectionView.layer.masksToBounds = false
        return collectionView
    }()
    
    // MARK: - Filter
    lazy var filterContainerView = UIView(backgroundColor: .white)
    lazy var filterButton: LeftAlignedIconButton = {
        let space: CGFloat = 10
        let button = LeftAlignedIconButton(height: 35, label: "filter".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .semibold), backgroundColor: .f3f5fa, textColor: .a5a7bd, cornerRadius: 10, contentInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 12 + space))
        button.textToImageSpace = space
        button.setImage(UIImage(named: "filter"), for: .normal)
        return button
    }()
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        
        addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        shadowView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        
        contentView.addSubview(carousel)
        carousel.autoPinEdge(toSuperviewSafeArea: .top)
        carousel.autoAlignAxis(toSuperviewAxis: .vertical)
        carousel.autoSetDimension(.width, toSize: 300)
        carousel.delegate = self
        carousel.dataSource = self
        
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: carousel, withOffset: 25)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        contentView.addSubview(pointLabel)
        pointLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        pointLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // balance
        balanceContainerView.addSubview(communValueLabel)
        communValueLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 5)
        communValueLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        balanceContainerView.addSubview(progressView)
        progressView.autoPinEdge(.top, to: .bottom, of: communValueLabel, withOffset: 32 * Config.heightRatio)
        progressView.autoPinEdge(toSuperviewEdge: .leading, withInset: 22 * Config.widthRatio)
        progressView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 22 * Config.widthRatio)
        
        let label = UILabel.with(textSize: 12, textColor: .white)
        label.attributedText = NSMutableAttributedString()
            .text("available".localized().uppercaseFirst, size: 12, color: .white)
            .text("/" + "hold".localized().uppercaseFirst, size: 12, color: UIColor.white.withAlphaComponent(0.5))
        
        balanceContainerView.addSubview(label)
        label.autoPinEdge(.leading, to: .leading, of: progressView)
        label.autoPinEdge(.top, to: .bottom, of: progressView, withOffset: 12)
        label.autoPinEdge(toSuperviewEdge: .bottom)
        
        balanceContainerView.addSubview(availableHoldValueLabel)
        availableHoldValueLabel.autoPinEdge(.top, to: .bottom, of: progressView, withOffset: 12)
        availableHoldValueLabel.autoPinEdge(.trailing, to: .trailing, of: progressView)
        
        // stackView
        contentView.addSubview(buttonsStackView)
        stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: pointLabel, withOffset: 30 * Config.heightRatio)
        buttonsStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16 * Config.widthRatio, bottom: 30 * Config.heightRatio, right: 16 * Config.widthRatio), excludingEdge: .top)
        
        buttonsStackView.addArrangedSubview(buttonContainerViewWithButton(sendButton, label: "send".localized().uppercaseFirst))
        buttonsStackView.addArrangedSubview(buttonContainerViewWithButton(convertButton, label: "convert".localized().uppercaseFirst))
        
        // my points
        addSubview(myPointsContainerView)
        myPointsContainerView.autoPinEdge(.top, to: .bottom, of: shadowView, withOffset: 29)
        myPointsContainerView.autoPinEdge(toSuperviewEdge: .leading)
        myPointsContainerView.autoPinEdge(toSuperviewEdge: .trailing)
        
        let myPointsLabel = UILabel.with(text: "my points".localized().uppercaseFirst, textSize: 17, weight: .bold)
        myPointsContainerView.addSubview(myPointsLabel)
        myPointsLabel.autoPinEdge(toSuperviewEdge: .top)
        myPointsLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        
        let myPointsSeeAllButton = UIButton(label: "see all".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .medium), textColor: .appMainColor, contentInsets: .zero)
        myPointsContainerView.addSubview(myPointsSeeAllButton)
        myPointsSeeAllButton.autoPinEdge(toSuperviewEdge: .top)
        myPointsSeeAllButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        
        myPointsSeeAllButton.addTarget(self, action: #selector(myPointsSeeAllDidTouch), for: .touchUpInside)
        
        myPointsContainerView.addSubview(myPointsCollectionView)
        myPointsCollectionView.autoPinEdge(.top, to: .bottom, of: myPointsLabel, withOffset: 20)
        myPointsCollectionView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        // send points
        addSubview(sendPointsContainerView)
        sendPointsTopConstraint = sendPointsContainerView.autoPinEdge(.top, to: .bottom, of: myPointsContainerView, withOffset: 30 * Config.heightRatio)
        sendPointsContainerView.autoPinEdge(toSuperviewEdge: .leading)
        sendPointsContainerView.autoPinEdge(toSuperviewEdge: .trailing)
        
        let sendPointsSeeAllButton = UIButton(label: "see all".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .medium), textColor: .appMainColor, contentInsets: .zero)
        sendPointsContainerView.addSubview(sendPointsSeeAllButton)
        sendPointsSeeAllButton.autoPinEdge(toSuperviewEdge: .top)
        sendPointsSeeAllButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        
        sendPointsSeeAllButton.addTarget(self, action: #selector(sendPointsSeeAllDidTouch), for: .touchUpInside)
        
        let sendPointsLabel = UILabel.with(text: "send points".localized().uppercaseFirst, textSize: 17, weight: .bold)
        sendPointsContainerView.addSubview(sendPointsLabel)
        sendPointsLabel.autoPinEdge(toSuperviewEdge: .top)
        sendPointsLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        
        sendPointsContainerView.addSubview(sendPointsCollectionView)
        sendPointsCollectionView.autoPinEdge(.top, to: .bottom, of: sendPointsLabel, withOffset: 20)
        sendPointsCollectionView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        // filter
        addSubview(filterContainerView)
        filterContainerView.autoPinEdge(.top, to: .bottom, of: sendPointsContainerView, withOffset: 32)
        filterContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        filterContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        
        let historyLabel = UILabel.with(text: "history".localized().uppercaseFirst, textSize: 17, weight: .bold)
        filterContainerView.addSubview(historyLabel)
        historyLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        historyLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        filterContainerView.addSubview(filterButton)
        filterButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        filterButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        filterButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // pin bottom
        filterContainerView.autoPinEdge(toSuperviewEdge: .bottom)
        
        // initial setup
        setUpWithCommunValue()
    }
    
    func setUp(with balances: [ResponseAPIWalletGetBalance]) {
        self.balances = balances
        if currentIndex == 0 {
            setUpWithCommunValue()
        } else {
            setUpWithCurrentBalance()
        }
        carousel.reloadData()
    }
    
    private func setUpWithCommunValue() {
        var point: Double = 0
        if let balances = balances {
            if balances.first?.symbol == "CMN",
                let communPoint = balances.first?.balance
            {
                point = Double(communPoint) ?? 0
            } else {
                point = balances.filter {$0.symbol != "CMN"}.reduce(0.0, { (result, balance) -> Double in
                    var result = result
                    result += balance.communValue
                    return result
                })
            }
            
        }
        // remove balanceContainerView if exists
        if balanceContainerView.isDescendant(of: contentView) {
            contentView.backgroundColor = .appMainColor
            balanceContainerView.removeFromSuperview()
            
            stackViewTopConstraint?.isActive = false
            stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: pointLabel, withOffset: 30 * Config.heightRatio)
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
        
        // set up
        titleLabel.text = "enquity Value Commun".localized().uppercaseFirst
        pointLabel.text = "\(point.currencyValueFormatted)"
        
    }
    
    private func setUpWithCurrentBalance() {
        guard let balances = balances,
            let balance = balances[safe: currentIndex]
        else {
            currentIndex = 0
            return
        }
        // add balanceContainerView
        if !balanceContainerView.isDescendant(of: contentView) {
            contentView.backgroundColor = UIColor(hexString: "#020202")
            contentView.addSubview(balanceContainerView)
            balanceContainerView.autoPinEdge(.top, to: .bottom, of: pointLabel)
            balanceContainerView.autoPinEdge(toSuperviewEdge: .leading)
            balanceContainerView.autoPinEdge(toSuperviewEdge: .trailing)
            
            stackViewTopConstraint?.isActive = false
            stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: balanceContainerView, withOffset: 30 * Config.heightRatio)
            
            UIView.transition(with: balanceContainerView, duration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        }
        
        // set up
        titleLabel.text = balance.name ?? "" + "balance".localized().uppercaseFirst
        pointLabel.text = "\(balance.balanceValue.currencyValueFormatted)"
        communValueLabel.text = "= \(balance.communValue.currencyValueFormatted)" + " " + "Commun"
        availableHoldValueLabel.attributedText = NSMutableAttributedString()
            .text("\(balance.balance)", size: 12, color: .white)
            .text("/\(balance.frozen ?? "0")", size: 12, color: UIColor.white.withAlphaComponent(0.5))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.roundCorners(UIRectCorner(arrayLiteral: .bottomLeft, .bottomRight), radius: 30 * Config.heightRatio)
        shadowView.addShadow(ofColor: UIColor(red: 106, green: 128, blue: 245)!, radius: 19, offset: CGSize(width: 0, height: 14), opacity: 0.3)
        filterContainerView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 16)
    }
    
    private func buttonContainerViewWithButton(_ button: UIButton, label: String) -> UIView {
        let container = UIView(forAutoLayout: ())
        container.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        button.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let label = UILabel.with(text: label, textSize: 12, textColor: .white)
        container.addSubview(label)
        label.autoPinEdge(.top, to: .bottom, of: button, withOffset: 7)
        label.autoAlignAxis(toSuperviewAxis: .vertical)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        return container
    }
    
    func startLoading() {
        contentView.showLoader()
    }
    
    func endLoading() {
        contentView.hideLoader()
    }
    
    @objc func sendPointsSeeAllDidTouch() {
        // TODO: see all
    }
    
    @objc func myPointsSeeAllDidTouch() {
        // TODO: see all
    }
}

extension WalletHeaderView: CircularCarouselDataSource, CircularCarouselDelegate {
    func startingItemIndex(inCarousel carousel: CircularCarousel) -> Int {
        return currentIndex
    }
    
    func numberOfItems(inCarousel carousel: CircularCarousel) -> Int {
        return min(maxItemsInCarousel, balances?.count ?? 0)
    }
    func carousel(_: CircularCarousel, viewForItemAt indexPath: IndexPath, reuseView: UIView?) -> UIView {
        guard let balances = balances,
            let balance = balances[safe: indexPath.row]
            else {
                return UIView()
        }
        
        var view = reuseView

        if view == nil || view?.viewWithTag(1) == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            let imageView = MyAvatarImageView(size: 44)
            imageView.borderColor = .white
            imageView.borderWidth = 2
            imageView.tag = 1
            view!.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        
        let imageView = view?.viewWithTag(1) as! MyAvatarImageView
        
        if balance.symbol == "CMN" {
            imageView.image = UIImage(named: "tux")
        } else {
            imageView.setAvatar(urlString: balance.logo, namePlaceHolder: balance.name ?? "B\(indexPath.row)")
        }
        
        return view!
    }
    // MARK: CircularCarouselDelegate
    func carousel<CGFloat>(_ carousel: CircularCarousel, valueForOption option: CircularCarouselOption, withDefaultValue defaultValue: CGFloat) -> CGFloat {
        if option == .itemWidth {
            return CoreGraphics.CGFloat(44) as! CGFloat
        }
        
        if option == .spacing {
            return CoreGraphics.CGFloat(8) as! CGFloat
        }
        
        if option == .minScale {
            return CoreGraphics.CGFloat(0.7) as! CGFloat
        }
        
        return defaultValue
    }
    
    func carousel(_ carousel: CircularCarousel, willBeginScrollingToIndex index: Int) {
        currentIndex = index
    }
}
