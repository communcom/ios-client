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
    // MARK: - Properties
    var dataModel: SendPointsModel
        
    lazy var carouselView: CircularCarousel = {
        let carouselViewInstance = CircularCarousel(width: .adaptive(width: 247.0), height: carouselHeight)
        carouselViewInstance.delegate = self
        carouselViewInstance.dataSource = self
        
        return carouselViewInstance
    }()

    let carouselHeight: CGFloat = .adaptive(height: 50.0)

    let whiteView = UIView(width: .adaptive(width: 375.0), height: .adaptive(height: 543.0), backgroundColor: .white, cornerRadius: .adaptive(width: 25.0))
    let pointsToolbar: CMToolbarView = CMToolbarView(frame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 375.0), height: .adaptive(height: 50.0))))

    lazy var communLogoImageView = UIView.transparentCommunLogo(size: .adaptive(width: 50.0))

    // Balance
    var sellerNameLabel: UILabel = {
        let balanceNameLabelInstance = UILabel()
        balanceNameLabelInstance.tune(withText: "",
                                      hexColors: whiteColorPickers,
                                      font: UIFont.systemFont(ofSize: .adaptive(width: 17.0), weight: .semibold),
                                      alignment: .center,
                                      isMultiLines: false)
        
        return balanceNameLabelInstance
    }()

    var sellerAmountLabel: UILabel = {
        let balanceCurrencyLabelInstance = UILabel()
        balanceCurrencyLabelInstance.tune(withText: "",
                                          hexColors: whiteColorPickers,
                                          font: UIFont.systemFont(ofSize: .adaptive(width: 30.0), weight: .bold),
                                          alignment: .center,
                                          isMultiLines: false)
        
        return balanceCurrencyLabelInstance
    }()

    // Friend
    var friendAvatarImageView = UIView.createCircleCommunLogo(side: .adaptive(height: 40.0))
    
    let friendNameLabel: UILabel = UILabel(text: "select user".localized().uppercaseFirst,
                                                font: .systemFont(ofSize: .adaptive(width: 15.0), weight: .semibold),
                                                numberOfLines: 1,
                                                color: .black)
    
    let chooseFriendButton: UIButton = {
        let chooseRecipientButtonInstance = UIButton.circle(size: .adaptive(width: 24.0),
                                                            backgroundColor: .clear,
                                                            tintColor: .white,
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
                                     textColors: blackWhiteColorPickers,
                                     font: .systemFont(ofSize: .adaptive(width: 17.0), weight: .semibold),
                                     alignment: .left)
        
        pointsTextFieldInstance.keyboardType = .decimalPad
        pointsTextFieldInstance.autocorrectionType = .no
        pointsTextFieldInstance.autocapitalizationType = .none

        return pointsTextFieldInstance
    }()

    let clearPointsButton: UIButton = {
        let clearPointsButtonInstance = UIButton.circle(size: .adaptive(width: 24.0),
                                                        backgroundColor: .clear,
                                                        tintColor: .white,
                                                        imageName: "icon-cancel-grey-cyrcle-default",
                                                        imageEdgeInsets: .zero)
        
        clearPointsButtonInstance.isHidden = true
        clearPointsButtonInstance.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        return clearPointsButtonInstance
    }()

    // MARK: - Class Initialization
    init(withSelectedBalanceSymbol symbol: String, andUser user: ResponseAPIContentGetProfile?) {
        self.dataModel = SendPointsModel()
        self.dataModel.transaction.symbol = Symbol(sell: symbol, buy: symbol)
        
        if let userValue = user  {
            self.dataModel.transaction.createFriend(from: userValue)
        }
        
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
                
        dataModel.loadBalances { [weak self] success in
            guard let strongSelf = self else { return }
            
            if success {
                strongSelf.setupView()
                strongSelf.addGesture()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavBar()
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setTabBarHidden(sendPointsButton.isSelected)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        pointsToolbar.frame.size = CGSize(width: .adaptive(width: 375.0), height: .adaptive(height: 50.0))
    }
    
    
    // MARK: - Custom Functions
    override func bind() {
        pointsTextField.delegate = self

        pointsTextField.rx.text
            .orEmpty
            .subscribe(onNext: { value in
                self.dataModel.transaction.amount = CGFloat(value.toDouble())
                self.updateSendInfoByEnteredPoints()
            })
            .disposed(by: disposeBag)
    }

    func setupView() {
        let balanceContentView = UIView(width: .adaptive(width: 375.0), height: .adaptive(height: 300.0), backgroundColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), cornerRadius: 0.0)
        view.addSubview(balanceContentView)
        balanceContentView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)

        let balanceStackView = UIStackView(axis: .vertical, spacing: .adaptive(height: 5.0))
        balanceStackView.alignment = .fill
        balanceStackView.distribution = .fillProportionally
        balanceStackView.addArrangedSubviews([sellerNameLabel, sellerAmountLabel])
        
        balanceContentView.addSubview(balanceStackView)
        balanceStackView.autoAlignAxis(toSuperviewAxis: .vertical)

        if dataModel.transaction.symbol.sell == Config.defaultSymbol {
            balanceContentView.addSubview(communLogoImageView)
            communLogoImageView.autoPinEdge(toSuperviewEdge: .top, withInset: .adaptive(height: 20.0))
            communLogoImageView.autoAlignAxis(toSuperviewAxis: .vertical)
            balanceStackView.autoPinEdge(.top, to: .bottom, of: communLogoImageView, withOffset: .adaptive(height: 20.0))
        } else {
            balanceContentView.addSubview(carouselView)
            carouselView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 64.0), vertical: .adaptive(height: 20.0)), excludingEdge: .bottom)

            balanceStackView.autoPinEdge(.top, to: .bottom, of: carouselView, withOffset: .adaptive(height: 20.0))
        }
        
        updateBuyerInfo()
        updateSellerInfo()
        dataModel.transaction.history == nil ? updateSendInfoByEnteredPoints() : updateSendInfoByHistory()

        // Action view
        whiteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(whiteView)
        whiteView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
                
        let firstBorderView = UIView(width: .adaptive(width: 345.0), height: .adaptive(height: 70.0), backgroundColor: .white, cornerRadius: .adaptive(width: 10.0))
        setup(borderedView: firstBorderView)
        whiteView.addSubview(firstBorderView)
        firstBorderView.autoPinTopAndLeadingToSuperView(inset: .adaptive(height: 20.0), xInset: .adaptive(width: 15.0))
        firstBorderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseRecipientViewTapped)))
        firstBorderView.isUserInteractionEnabled = true

        let recipientStackView = UIStackView(axis: .horizontal, spacing: .adaptive(width: 10.0))
        recipientStackView.alignment = .leading
        recipientStackView.distribution = .fill

        recipientStackView.addArrangedSubviews([friendAvatarImageView, friendNameLabel, chooseFriendButton])
        friendNameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        chooseFriendButton.autoAlignAxis(toSuperviewAxis: .horizontal)

        firstBorderView.addSubview(recipientStackView)
        recipientStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 30.0), vertical: .adaptive(height: 30.0)))
        
        let secondBorderView = UIView(width: .adaptive(width: 345.0), height: .adaptive(height: 64.0), backgroundColor: .white, cornerRadius: .adaptive(width: 10.0))
        setup(borderedView: secondBorderView)
        whiteView.addSubview(secondBorderView)
        secondBorderView.autoPinTopAndTrailingToSuperView(inset: .adaptive(height: 100.0), xInset: .adaptive(width: 15.0))
        
        let amountStackView = UIStackView(axis: .vertical, spacing: .adaptive(height: 8.0))
        amountStackView.alignment = .fill
        amountStackView.distribution = .fillProportionally
        
        let amountLabel = UILabel()
        amountLabel.tune(withText: "amount".localized().uppercaseFirst,
                         hexColors: grayishBluePickers,
                         font: .systemFont(ofSize: .adaptive(width: 12.0), weight: .semibold),
                         alignment: .left,
                         isMultiLines: false)
        
        amountStackView.addArrangedSubviews([amountLabel, pointsTextField])
        pointsTextField.inputAccessoryView = pointsToolbar

        secondBorderView.addSubview(amountStackView)
        amountStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 30.0), vertical: .adaptive(height: 22.0)))
        
        secondBorderView.addSubview(clearPointsButton)
        clearPointsButton.autoPinTopAndTrailingToSuperView(inset: .adaptive(height: 20.0), xInset: .adaptive(width: 15.0))
        
        whiteView.addSubview(sendPointsButton)
        sendPointsButton.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(horizontal: .adaptive(width: 30.0), vertical: .adaptive(height: 20.0)), excludingEdge: .top)
    }
    
    private func setupNavBar() {
        title = "send points".localized()

        setLeftNavBarButtonForGoingBack(tintColor: .white)
        view.backgroundColor = #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // items color
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1) // bar color
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage?.clear()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        if self.dataModel.transaction.symbol != Symbol(sell: "CMN", buy: "CMN") {
            setRightBarButton(imageName: "wallet-right-bar-button", tintColor: .white, action: #selector(pointsListButtonDidTouch))
        }
        
        setTabBarHidden(true)
    }
    
    private func setup(borderedView: UIView) {
        borderedView.translatesAutoresizingMaskIntoConstraints = false
        borderedView.layer.borderColor = UIColor.e2e6e8.cgColor
        borderedView.layer.borderWidth = 1.0
        borderedView.clipsToBounds = true
    }
    
    private func setSendButton(amount: CGFloat = 0.0, percent: CGFloat) {
        let subtitle1 = String(format: "%@: %@ %@", "send".localized().uppercaseFirst, Double(amount).currencyValueFormatted, dataModel.transaction.symbol.sell.fullName)
        var title: NSMutableAttributedString!
        var subtitle2 = ""
        
        if percent > 0 {
            subtitle2 = String(format: "%.1f%% %@", percent, "will be burned 🔥".localized())
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
                             NSAttributedString.Key.foregroundColor: UIColor(hexString: "#ffffff", transparency: 0.7)!,
                             NSAttributedString.Key.paragraphStyle: style
                            ], range: NSRange(location: subtitle1.count + 1, length: subtitle2.count))

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
        sellerAmountLabel.text = sellBalance.amount == 0 ? "0" : Double(sellBalance.amount).currencyValueFormatted
    }
    
    private func updateBuyerInfo() {
        chooseFriendButton.isSelected = dataModel.transaction.friend?.name != nil

        if let friendName = dataModel.transaction.friend?.name {
            friendNameLabel.text = friendName
            friendAvatarImageView.addCircleImage(byURL: dataModel.transaction.friend?.avatarURL, withPlaceholderName: friendName, andSide: .adaptive(height: 40.0))
        } else {
            friendNameLabel.text = "select user".localized().uppercaseFirst
        }
    }

    private func updateSendInfoByHistory() {
        let amount = CGFloat(dataModel.transaction.history!.quantityValue)
        let accuracy = amount >= 1_000.0 ? 2 : 4

        setSendButton(amount: amount, percent: 0.1)
        pointsTextField.text = String(format: "%.*f", accuracy, amount)

        sendPointsButton.isDisabled = dataModel.checkHistoryAmounts() && chooseFriendButton.isSelected
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
        }
        
        else {
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
        
        let nc = BaseNavigationController(rootViewController: vc)
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
        
        let nc = BaseNavigationController(rootViewController: friendsListVC)
        present(nc, animated: true, completion: nil)        
    }

    @objc func clearButtonTapped(_ sender: UIButton) {
        sender.isHidden = true
        pointsTextField.text = nil
        dataModel.transaction.amount = 0
        
        updateSendInfoByEnteredPoints()
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

            BlockchainManager.instance.transferPoints(to: friendID, number: Double(numberValue), currency: self.dataModel.transaction.symbol.sell)
                .flatMapCompletable { RestAPIManager.instance.waitForTransactionWith(id: $0) }
                .subscribe(onCompleted: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    if let baseNC = strongSelf.navigationController as? BaseNavigationController {
                        baseNC.shouldResetNavigationBarOnPush = false
                        let completedVC = TransactionCompletedVC(transaction: strongSelf.dataModel.transaction)
                        strongSelf.show(completedVC, sender: nil)
                    }

                    strongSelf.hideHud()
                    strongSelf.sendPointsButton.isSelected = true
                }) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.hideHud()
                    strongSelf.showError(error)
                    strongSelf.sendPointsButton.isSelected = false
            }
            .disposed(by: self.disposeBag)
            //*/
        }
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
        guard !string.isEmpty else { return true }
        guard let text = textField.text, !(text.starts(with: "0") && string == "0") else { return false }
        guard CharacterSet(charactersIn: "0123456789.,").isSuperset(of: CharacterSet(charactersIn: string)) else { return false }
        
        let updatedText = text + string
        let countDots = (text + string).filter({$0 == "."}).count
        let countCommas = (text + string).filter({$0 == ","}).count
        
        guard countDots + countCommas <= 1 else { return false }
        guard !updatedText.hasSuffix(".") || !updatedText.hasSuffix(",") else { return false }
        guard CGFloat(updatedText.float() ?? 0.0) <= dataModel.getBalance(bySymbol: dataModel.transaction.symbol.sell).amount else { return false }
        
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
            imageView.borderColor = .white
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
            imageView.setAvatar(urlString: balance.logo, namePlaceHolder: balance.name ?? balance.symbol)
        }
        
        return view!
    }
    
    func startingItemIndex(inCarousel carousel: CircularCarousel) -> Int {
        return dataModel.balances.firstIndex(where: { $0.symbol == dataModel.transaction.symbol.sell }) ?? 0
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
