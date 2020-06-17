//
//  PointsSendViewController.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 23.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift
import CircularCarousel

class WalletSendPointsVC: BaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {.lightContent}
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.normal(translucent: true, backgroundColor: .clear, font: .boldSystemFont(ofSize: 17), textColor: .white)}
    override var shouldHideTabBar: Bool {true}
    var actionName: String {"send"}
    var memo = ""
    
    // MARK: - Properties
    var dataModel: SendPointsModel
    var buttonBottomConstraint: NSLayoutConstraint?

    private let carouselHeight: CGFloat = 50

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentSize = UIScreen.main.bounds.size
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = false
        
        return scrollView
    }()

    lazy var carouselView: CircularCarousel = {
        let carouselViewInstance = CircularCarousel(width: .adaptive(width: 247.0), height: carouselHeight)
        carouselViewInstance.delegate = self
        carouselViewInstance.dataSource = self

        return carouselViewInstance
    }()

    let topView: UIView = {
        return UIView(height: 225, backgroundColor: .appMainColor)
    }()

    let whiteView = UIView(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height - 269,
                           backgroundColor: .appWhiteColor,
                           cornerRadius: 25)
    
    lazy var userView = UIView(height: 70)

    let pointsToolbar: CMToolbarView = CMToolbarView(frame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 375.0), height: .adaptive(height: 50.0))))

    lazy var communLogoImageView = UIView.transparentCommunLogo(size: carouselHeight)

    // Balance
    var sellerNameLabel = UILabel.with(textSize: .adaptive(width: 17.0), weight: .semibold, textColor: .white, textAlignment: .center)

    var sellerAmountLabel = UILabel.with(textSize: .adaptive(width: 30.0), weight: .bold, textColor: .white, textAlignment: .center)

    // Friend
    var friendAvatarImageView = UIView.createCircleCommunLogo(side: 40)
    
    let friendNameLabel: UILabel = UILabel(text: "select user".localized().uppercaseFirst,
                                           font: .systemFont(ofSize: 15, weight: .semibold),
                                           numberOfLines: 1,
                                           color: .appBlackColor)
    
    let chooseFriendButton: UIButton = {
        let chooseRecipientButtonInstance = UIButton.circle(size: 24,
                                                            backgroundColor: .clear,
                                                            tintColor: .appWhiteColor,
                                                            imageName: "icon-select-user-grey-cyrcle-default",
                                                            imageEdgeInsets: .zero)
        
        chooseRecipientButtonInstance.setImage(UIImage(named: "icon-select-user-green-cyrcle-selected"), for: .selected)

        return chooseRecipientButtonInstance
    }()
    
    let sendPointsButton: CommunButton = {
        let sendPointsButtonInstance = CommunButton.default(height: 50.0, isDisabled: true)
        sendPointsButtonInstance.addTarget(self, action: #selector(sendPointsButtonTapped), for: .touchUpInside)
        
        return sendPointsButtonInstance
    }()
    
    let pointsTextField: UITextField = {
        let pointsTextFieldInstance = UITextField()
        pointsTextFieldInstance.tune(withPlaceholder: String(format: "0 %@", "points".localized().uppercaseFirst),
                                     textColor: .appBlackColor,
                                     font: .systemFont(ofSize: 17, weight: .semibold),
                                     alignment: .left)
        
        pointsTextFieldInstance.keyboardType = .decimalPad
        pointsTextFieldInstance.autocorrectionType = .no
        pointsTextFieldInstance.autocapitalizationType = .none

        return pointsTextFieldInstance
    }()

    let clearPointsButton: UIButton = {
        let clearPointsButtonInstance = UIButton.circle(size: 24,
                                                        backgroundColor: .clear,
                                                        tintColor: .appWhiteColor,
                                                        imageName: "icon-cancel-grey-cyrcle-default",
                                                        imageEdgeInsets: .zero)
        
        clearPointsButtonInstance.isHidden = true
        clearPointsButtonInstance.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        return clearPointsButtonInstance
    }()

    var sellerNameLabelForNavBar: UILabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12, weight: .bold), numberOfLines: 1, color: .white)
    var sellerAmountLabelForNavBar: UILabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 20, weight: .bold), numberOfLines: 1, color: .white)
    var navigationBarTitleView = UIView(forAutoLayout: ())

    var amountBorderView = UIView(forAutoLayout: ())
    var alertLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 12, weight: .bold), numberOfLines: 2, color: .appRedColor)

    // MARK: - Class Initialization
    init(selectedBalanceSymbol symbol: String, user: ResponseAPIContentGetProfile?) {
        self.dataModel = SendPointsModel()
        self.dataModel.transaction.symbol = Symbol(sell: symbol, buy: symbol)
        
        if let userValue = user  {
            self.dataModel.transaction.createFriend(from: userValue)
        }
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                
        dataModel.loadBalances { [weak self] success in
            if success {
                self?.balancesDidFinishLoading()
            }
        }
        
        pointsToolbar.addCompletion = { [weak self] value in
            guard let strongSelf = self else { return }
            
            let enteredAmount = value + strongSelf.dataModel.transaction.amount
            
            guard enteredAmount <= strongSelf.dataModel.getBalance(bySymbol: strongSelf.dataModel.transaction.symbol.sell).amount else { return }

            strongSelf.dataModel.transaction.amount = enteredAmount
            strongSelf.pointsTextField.text = String(Double(enteredAmount).currencyValueFormatted)
            strongSelf.clearPointsButton.isHidden = false
            strongSelf.updateSendInfoByEnteredPoints()
        }
        
        bind()
    }

    @objc func keyboardWillShow(notification: Notification) {
        self.view.layoutIfNeeded()
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.buttonBottomConstraint?.constant = -keyboardSize.height - 10
        }
        let y = (navigationController?.navigationBar.frame.size.height ?? 0) + (navigationController?.navigationBar.frame.origin.y ?? 0)
        scrollView.contentInset.top = y
        scrollView.contentOffset.y = -y
        navigationItem.titleView = navigationBarTitleView
        
        carouselView.isHidden = true

        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide() {
        scrollView.contentOffset.y = -270
        scrollView.contentInset.top = 270
        navigationItem.titleView = nil
        title = "send points".localized().uppercaseFirst

        self.view.layoutIfNeeded()
        self.buttonBottomConstraint?.constant = -30
        
        carouselView.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }

    private func setupUI() {
        view.backgroundColor = .appMainColor

        configureNavigationBarTitleView()
        configureTopView()

        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
        keyboardWillHide()
        // fix carusel
        view.bringSubviewToFront(carouselView)
        configureBottomView()
    }

    private func configureNavigationBarTitleView() {
        navigationBarTitleView.addSubview(sellerNameLabelForNavBar)
        navigationBarTitleView.addSubview(sellerAmountLabelForNavBar)

        sellerNameLabelForNavBar.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        sellerAmountLabelForNavBar.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        sellerAmountLabelForNavBar.autoPinEdge(.top, to: .bottom, of: sellerNameLabelForNavBar)

        sellerNameLabelForNavBar.textAlignment = .center
        sellerAmountLabelForNavBar.textAlignment = .center
    }

    private func configureTopView() {
        view.addSubview(topView)
        topView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)

        // add carouselView or commun logo
        if dataModel.transaction.symbol.sell == Config.defaultSymbol {
            topView.addSubview(communLogoImageView)
            communLogoImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            communLogoImageView.autoAlignAxis(toSuperviewAxis: .vertical)
            communLogoImageView.autoPinEdge(.top, to: .top, of: topView, withOffset: 20)
        } else {
            view.addSubview(carouselView)
            carouselView.autoAlignAxis(toSuperviewAxis: .vertical)
            carouselView.autoPinEdge(.top, to: .top, of: topView, withOffset: 20)
        }

        topView.addSubview(sellerNameLabel)
        sellerNameLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        sellerNameLabel.autoPinEdge(.top, to: .top, of: topView, withOffset: 90)

        topView.addSubview(sellerAmountLabel)
        sellerAmountLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        sellerAmountLabel.autoPinEdge(.top, to: .bottom, of: sellerNameLabel, withOffset: 5)
    }

    private func configureBottomView() {
        whiteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        scrollView.addSubview(whiteView)

        whiteView.autoPinEdge(toSuperviewEdge: .left)
        whiteView.autoPinEdge(toSuperviewEdge: .right)
        whiteView.autoPinEdge(toSuperviewEdge: .top)

        // user view
        userView.layer.cornerRadius = 10
        userView.layer.borderWidth = 1
        userView.layer.borderColor = UIColor.appLightGrayColor.cgColor

        whiteView.addSubview(userView)
        userView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15), excludingEdge: .bottom)

        let userStackView = UIStackView(axis: .horizontal, spacing: 10)
        userStackView.alignment = .leading
        userStackView.distribution = .fill

        userStackView.addArrangedSubviews([friendAvatarImageView, friendNameLabel, chooseFriendButton])
        friendNameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        chooseFriendButton.autoAlignAxis(toSuperviewAxis: .horizontal)

        userView.addSubview(userStackView)
        userStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: 30, vertical: 30))

        userView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseRecipientViewTapped)))
        userView.isUserInteractionEnabled = true

        // amount view
        let amountView = UIView(height: 70)
        amountView.layer.cornerRadius = 10
        amountView.layer.borderWidth = 1
        amountView.layer.borderColor = UIColor.appLightGrayColor.cgColor
        amountBorderView = amountView

        whiteView.addSubview(amountView)
        amountView.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        amountView.autoPinEdge(toSuperviewEdge: .right, withInset: 15)
        amountView.autoPinEdge(.top, to: .bottom, of: userView, withOffset: 10)

        let amountLabel = UILabel(text: "amount".localized().uppercaseFirst, font: UIFont.systemFont(ofSize: 12, weight: .semibold), color: .appGrayColor)
        amountView.addSubview(amountLabel)
        amountLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        amountLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 11)

        amountView.addSubview(pointsTextField)

        pointsTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 33, left: 15, bottom: 11, right: 30))

        amountView.addSubview(clearPointsButton)
        clearPointsButton.autoPinTopAndTrailingToSuperView(inset: 33, xInset: 15)

        whiteView.addSubview(alertLabel)
        alertLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        alertLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 15)
        alertLabel.autoPinEdge(.top, to: .bottom, of: amountView, withOffset: 10)

        view.addSubview(sendPointsButton)

        sendPointsButton.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        sendPointsButton.autoPinEdge(toSuperviewEdge: .right, withInset: 15)
        buttonBottomConstraint = sendPointsButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 10)
    }
    
    func balancesDidFinishLoading() {
        setupUI()
        updateBuyerInfo()
        updateSellerInfo()
        addGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        pointsToolbar.frame.size = CGSize(width: .adaptive(width: 375.0), height: .adaptive(height: 50.0))
    }

    // MARK: - Custom Functions
    override func bind() {
        super.bind()
        pointsTextField.delegate = self

        pointsTextField.rx.text
            .orEmpty
            .subscribe(onNext: { value in
                self.updateAmount(value.toDouble())
            })
            .disposed(by: disposeBag)
    }
    
    func updateAmount(_ amount: Double) {
        dataModel.transaction.amount = CGFloat(amount)
        updateSendInfoByEnteredPoints()
    }

    private func setupNavBar() {
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        view.backgroundColor = .appMainColor
        
        if self.dataModel.transaction.symbol != Symbol(sell: "CMN", buy: "CMN") {
            setRightBarButton(imageName: "wallet-right-bar-button", tintColor: .appWhiteColor, action: #selector(pointsListButtonDidTouch))
        }
    }
    
    private func setup(borderedView: UIView) {
        borderedView.translatesAutoresizingMaskIntoConstraints = false
        borderedView.layer.borderColor = UIColor.appLightGrayColor.cgColor
        borderedView.layer.borderWidth = 1.0
        borderedView.clipsToBounds = true
    }
    
    private func setSendButton(amount: CGFloat = 0.0, percent: CGFloat) {
        let subtitle1 = String(format: "%@: %@ %@", actionName.localized().uppercaseFirst, Double(amount).currencyValueFormatted, dataModel.transaction.symbol.sell.fullName)
        var title: NSMutableAttributedString!
        var subtitle2 = ""
        
        if percent > 0 {
            subtitle2 = String(format: "%.1f%% %@", percent, "will be burned")
            title = NSMutableAttributedString(string: "\(subtitle1)\n\(subtitle2)")
        } else {
            title = NSMutableAttributedString(string: subtitle1)
        }

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.paragraphSpacingBefore = 1.0
        style.paragraphSpacing = 1.0
        
        title.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0, weight: .bold),
                             NSAttributedString.Key.foregroundColor: UIColor.white,
                             NSAttributedString.Key.paragraphStyle: style
                            ], range: NSRange(location: 0, length: subtitle1.count))

        title.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0, weight: .semibold),
                             NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(1),
                             NSAttributedString.Key.paragraphStyle: style
                            ], range: NSRange(location: subtitle1.count + 1, length: subtitle2.count))

        if percent > 0 {
            title.append(NSAttributedString(string: " 🔥"))
        }

        sendPointsButton.setAttributedTitle(title, for: .normal)
        sendPointsButton.titleLabel?.lineBreakMode = .byWordWrapping
        sendPointsButton.titleLabel?.numberOfLines = 0
    }
    
    private func addGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    private func updateSellerInfo() {
        let sellBalance = dataModel.getBalance(bySymbol: dataModel.transaction.symbol.sell)
        sellerNameLabel.text = sellBalance.name
        sellerNameLabelForNavBar.text = sellBalance.name
        sellerAmountLabel.text = sellBalance.amount == 0 ? "0" : Double(sellBalance.amount).currencyValueFormatted
        sellerAmountLabelForNavBar.text = sellBalance.amount == 0 ? "0" : Double(sellBalance.amount).currencyValueFormatted
    }
    
    private func updateBuyerInfo() {
        chooseFriendButton.isSelected = dataModel.transaction.friend?.name != nil

        if let friendName = dataModel.transaction.friend?.name {
            friendNameLabel.text = friendName
            friendAvatarImageView.addCircleImage(imageURL: dataModel.transaction.friend?.avatarURL, side: 40)
        } else {
            friendNameLabel.text = "select user".localized().uppercaseFirst
        }
    }

    func updateSendInfoByHistory() {
         guard let history = dataModel.transaction.history else { return }
         
         let amount = CGFloat(history.quantityValue)
         let accuracy = amount >= 1_000.0 ? 2 : 4

         setSendButton(amount: amount, percent: 0.1)
         pointsTextField.text = String(format: "%.*f", accuracy, amount)

         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
             self.sendPointsButton.isDisabled = self.dataModel.checkHistoryAmounts() && self.chooseFriendButton.isSelected
         }
     }

    private func updateSendInfoByEnteredPoints() {
        guard let text = pointsTextField.text else { return }
        
        let amountEntered = CGFloat(text.toDouble())
        dataModel.transaction.amount = amountEntered
        let isCMN = dataModel.transaction.symbol.sell == Config.defaultSymbol
        setSendButton(amount: dataModel.transaction.amount, percent: isCMN ? 0.0 : 0.1)
        pointsTextField.placeholder = String(format: "0 %@", dataModel.transaction.symbol.sell.fullName)

        sendPointsButton.isDisabled = !(dataModel.checkEnteredAmounts() && chooseFriendButton.isSelected)
    }

    private func checkValues() -> Bool {
        guard sendPointsButton.isDisabled else { return true }

        let sendPointsButtonFrame = view.convert(sendPointsButton.frame, from: whiteView)

        if !chooseFriendButton.isSelected {
            self.hintView?.display(inPosition: sendPointsButtonFrame.origin, withType: .chooseFriend, completion: {})
        } else {
            self.hintView?.display(inPosition: sendPointsButtonFrame.origin, withType: .enterAmount, completion: {})
        }
        
        return false
    }

    // MARK: - Actions
    @objc func pointsListButtonDidTouch() {
        let vc = BalancesVC { balance in
            guard let selectedBalanceIndex = self.dataModel.balances.firstIndex(where: { $0.symbol == balance.symbol }) else { return }

            self.carouselView.scroll(toItemAtIndex: selectedBalanceIndex, animated: true)
            self.updateSellerInfo()
            self.updateSendInfoByEnteredPoints()
        }
        
        let nc = SwipeNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func chooseRecipientViewTapped(_ sender: UITapGestureRecognizer) {
        let friendsListVC = SendPointListVC()
        friendsListVC.completion = { [weak self] user in
           guard let strongSelf = self else { return }
           
           strongSelf.dataModel.transaction.createFriend(from: user)
           strongSelf.chooseFriendButton.isSelected = true
           strongSelf.updateBuyerInfo()
           strongSelf.updateSendInfoByEnteredPoints()
        }
        
        let nc = SwipeNavigationController(rootViewController: friendsListVC)
        present(nc, animated: true, completion: nil)        
    }

    @objc func clearButtonTapped(_ sender: UIButton) {
        sender.isHidden = true
        pointsTextField.text = nil
        updateAmount(0)
    }

    @objc func sendPointsButtonTapped(_ sender: UITapGestureRecognizer) {
        guard checkValues() else { return }
        
        let confirmPasscodeVC = ConfirmPasscodeVC()
        present(confirmPasscodeVC, animated: true, completion: nil)
        
        confirmPasscodeVC.completion = {
            let numberValue = abs(self.dataModel.transaction.amount)

            guard let friendID = self.dataModel.transaction.friend?.id, numberValue > 0 else { return }

            self.dataModel.transaction.operationDate = Date()
            
            self.showIndetermineHudWithMessage("sending".localized().uppercaseFirst + " \(self.dataModel.transaction.symbol.sell.fullName.uppercased())")

            BlockchainManager.instance.transferPoints(to: friendID, number: Double(numberValue), currency: self.dataModel.transaction.symbol.sell, memo: self.memo)
                .flatMapCompletable { RestAPIManager.instance.waitForTransactionWith(id: $0) }
                .subscribe(onCompleted: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.sendPointsDidComplete()
                }) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.hideHud()
                    strongSelf.showError(error)
                    strongSelf.sendPointsButton.isSelected = false
            }
            .disposed(by: self.disposeBag)
        }
    }
    
    func sendPointsDidComplete() {
        hideHud()
        sendPointsButton.isSelected = true
        showCheck()
    }
    
    func showCheck() {
        let completedVC = TransactionCompletedVC(transaction: dataModel.transaction)
        show(completedVC, sender: nil)
    }
    
    @objc func viewTapped( _ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension WalletSendPointsVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        clearPointsButton.isHidden = textField.text == ""
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        clearPointsButton.isHidden = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        guard let swiftRange = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: swiftRange, with: string)
        guard CharacterSet(charactersIn: "0123456789.,").isSuperset(of: CharacterSet(charactersIn: string)) else { return false }

        let countDots = updatedText.filter({$0 == "."}).count
        let countCommas = updatedText.filter({$0 == ","}).count

        guard countDots + countCommas <= 1 else { return false }
        guard !updatedText.hasSuffix(".") || !updatedText.hasSuffix(",") else { return false }

        if CGFloat(updatedText.float() ?? 0.0) <= dataModel.getBalance(bySymbol: dataModel.transaction.symbol.sell).amount {
            amountBorderView.layer.borderColor = UIColor.appLightGrayColor.cgColor
            alertLabel.text = nil
        } else {
            amountBorderView.layer.borderColor = UIColor.appRedColor.cgColor
            alertLabel.text = "Insufficient funds: \(dataModel.getBalance(bySymbol: dataModel.transaction.symbol.sell).amount) \(dataModel.transaction.symbol.sell)"
        }
        
        if updatedText.count > 1 && updatedText.starts(with: "0") && !(updatedText.contains(",") || updatedText.contains(".")) {
            textField.text = nil
        }
        
        clearPointsButton.isHidden = text.count == 1
        
        return true
    }
}

// MARK: - CircularCarouselDataSource
extension WalletSendPointsVC: CircularCarouselDataSource {
    func numberOfItems(inCarousel carousel: CircularCarousel) -> Int {
        return dataModel.balances.count
    }
    
    func carousel(_: CircularCarousel, viewForItemAt indexPath: IndexPath, reuseView view: UIView?) -> UIView {
        let balance = dataModel.balances[indexPath.row]
        var view = view

        if view == nil || view?.viewWithTag(1) == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: carouselHeight, height: carouselHeight))
            
            let imageView = MyAvatarImageView(size: carouselHeight)
            imageView.borderColor = .appWhiteColor
            imageView.borderWidth = 2
            imageView.tag = 1
            
            view!.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        
        let imageView = view?.viewWithTag(1) as! MyAvatarImageView
        
        if balance.symbol == Config.defaultSymbol {
            imageView.image = UIImage(named: "tux")
        } else {
            imageView.setAvatar(urlString: balance.logo)
        }

        updateSellerInfo()
        updateSendInfoByEnteredPoints()
        
        return view!
    }
    
    func startingItemIndex(inCarousel carousel: CircularCarousel) -> Int {
        return dataModel.balances.firstIndex(where: { $0.symbol == dataModel.transaction.symbol.sell }) ?? dataModel.balances.firstIndex(where: { $0.symbol == Config.defaultSymbol }) ?? 0
    }
}

// MARK: - CircularCarouselDelegate
extension WalletSendPointsVC: CircularCarouselDelegate {
    func carousel<CGFloat>(_ carousel: CircularCarousel, valueForOption option: CircularCarouselOption, withDefaultValue defaultValue: CGFloat) -> CGFloat {
        if option == .itemWidth {
            return CoreGraphics.CGFloat(carouselHeight) as! CGFloat
        }
        
        if option == .scaleMultiplier {
            return CoreGraphics.CGFloat(0.25) as! CGFloat
        }
        
        if option == .minScale {
            return CoreGraphics.CGFloat(0.5) as! CGFloat
        }
                
        if option == .visibleItems {
            return Int(5) as! CGFloat
        }
        
        return defaultValue
    }
    
    func carousel(_ carousel: CircularCarousel, didSelectItemAtIndex index: Int) {
        let selectedSymbol = dataModel.balances[index].symbol
        dataModel.transaction.symbol = Symbol(sell: selectedSymbol, buy: selectedSymbol)
        updateSellerInfo()
        updateSendInfoByEnteredPoints()
    }
    
    func carousel(_ carousel: CircularCarousel, willBeginScrollingToIndex index: Int) {
        let selectedSymbol = dataModel.balances[index].symbol
        dataModel.transaction.symbol = Symbol(sell: selectedSymbol, buy: selectedSymbol)
    }
}
