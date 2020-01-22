//
//  PointsSendViewController.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 23.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import CircularCarousel

class WalletSendPointsVC: UIViewController {
    // MARK: - Properties
    var dataModel: SendPointsModel
    
    lazy var carouselView: CircularCarousel = {
        let carouselViewInstance = CircularCarousel(width: CGFloat.adaptive(width: 247.0), height: carouselHeight)
        carouselViewInstance.delegate = self
        carouselViewInstance.dataSource = self
        
        return carouselViewInstance
    }()

    let carouselHeight: CGFloat = CGFloat.adaptive(height: 50.0)

    let pointsToolbar: CMToolbarView = CMToolbarView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 375.0), height: CGFloat.adaptive(height: 50.0))))

    lazy var communLogoImageView = UIView.transparentCommunLogo(size: CGFloat.adaptive(width: 50.0))

    // Balance
    var balanceNameLabel: UILabel = {
        let balanceNameLabelInstance = UILabel()
        balanceNameLabelInstance.tune(withText: "",
                                      hexColors: whiteColorPickers,
                                      font: UIFont.systemFont(ofSize: CGFloat.adaptive(width: 17.0), weight: .semibold),
                                      alignment: .center,
                                      isMultiLines: false)
        
        return balanceNameLabelInstance
    }()

    var balanceCurrencyLabel: UILabel = {
        let balanceCurrencyLabelInstance = UILabel()
        balanceCurrencyLabelInstance.tune(withText: "",
                                          hexColors: whiteColorPickers,
                                          font: UIFont.systemFont(ofSize: CGFloat.adaptive(width: 30.0), weight: .bold),
                                          alignment: .center,
                                          isMultiLines: false)
        
        return balanceCurrencyLabelInstance
    }()

    // Recipient
    var recipientAvatarImageView: UIImageView = UIImageView.circle(size: CGFloat.adaptive(width: 40.0), imageName: "tux")
    
    let recipientNameLabel: UILabel = UILabel(text: "select user".localized().uppercaseFirst,
                                                font: .systemFont(ofSize: CGFloat.adaptive(width: 15.0), weight: .semibold),
                                                numberOfLines: 1,
                                                color: .black)
    
    let chooseRecipientButton: UIButton = {
        let chooseRecipientButtonInstance = UIButton.circle(size: CGFloat.adaptive(width: 24.0),
                                                            backgroundColor: .clear,
                                                            tintColor: .white,
                                                            imageName: "icon-select-user-grey-cyrcle-default",
                                                            imageEdgeInsets: .zero)
        
        chooseRecipientButtonInstance.setImage(UIImage(named: "icon-select-user-green-cyrcle-selected"), for: .selected)

        return chooseRecipientButtonInstance
    }()
    
    let sendPointsButton: CommunButton = {
        let sendPointsButtonInstance = CommunButton.default(height: CGFloat.adaptive(height: 50.0))
        sendPointsButtonInstance.addTarget(self, action: #selector(sendPointsButtonTapped), for: .touchUpInside)
        sendPointsButtonInstance.isEnabled = false
        
        return sendPointsButtonInstance
    }()
    
    let pointsTextField: UITextField = {
        let pointsTextFieldInstance = UITextField()
        pointsTextFieldInstance.tune(withPlaceholder: String(format: "0 %@", "points".localized().uppercaseFirst),
                                     textColors: blackWhiteColorPickers,
                                     font: .systemFont(ofSize: CGFloat.adaptive(width: 17.0), weight: .semibold),
                                     alignment: .left)
        
        pointsTextFieldInstance.keyboardType = .decimalPad
        pointsTextFieldInstance.autocorrectionType = .no
        pointsTextFieldInstance.autocapitalizationType = .none

        return pointsTextFieldInstance
    }()

    let clearPointsButton: UIButton = {
        let clearPointsButtonInstance = UIButton.circle(size: CGFloat.adaptive(width: 24.0),
                                                        backgroundColor: .clear,
                                                        tintColor: .white,
                                                        imageName: "icon-cancel-grey-cyrcle-default",
                                                        imageEdgeInsets: .zero)
        
        clearPointsButtonInstance.isHidden = true
        clearPointsButtonInstance.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        return clearPointsButtonInstance
    }()
    
    
    // MARK: - Class Initialization
    init(withSelectedBalanceSymbol symbol: String, andFriend friend: ResponseAPIContentGetSubscriptionsUser?) {
        self.dataModel = SendPointsModel()
        self.dataModel.transaction.symbol = symbol
        
        if let recipient = friend  {
            self.dataModel.transaction.update(recipient: recipient)
        }

        super.init(nibName: nil, bundle: nil)
    }

    init(withSelectedBalanceSymbol symbol: String, andRecipient recipient: Recipient) {
        self.dataModel = SendPointsModel()
        self.dataModel.transaction.symbol = symbol
        self.dataModel.transaction.recipient = recipient

        super.init(nibName: nil, bundle: nil)
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
        
        pointsTextField.delegate = self
        
        pointsToolbar.addCompletion = { [weak self] value in
            guard let strongSelf = self else { return }
            
            let newAmount = value + strongSelf.dataModel.transaction.amount
            strongSelf.dataModel.transaction.amount = newAmount
            strongSelf.pointsTextField.text = String(format: "%.*f", strongSelf.dataModel.transaction.accuracy, newAmount)
            strongSelf.clearPointsButton.isHidden = false
            strongSelf.updateSendInfoByEnteredPoints()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavBar()
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.backgroundColor = .clear //#colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1)
        pointsToolbar.frame.size = CGSize(width: CGFloat.adaptive(width: 375.0), height: CGFloat.adaptive(height: 50.0))
    }
    
    
    // MARK: - Custom Functions
    func setupView() {
        let balanceContentView = UIView(width: CGFloat.adaptive(width: 375.0), height: CGFloat.adaptive(height: 300.0), backgroundColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), cornerRadius: 0.0)
        view.addSubview(balanceContentView)
        balanceContentView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)

        let balanceStackView = UIStackView(axis: .vertical, spacing: CGFloat.adaptive(height: 5.0))
        balanceStackView.alignment = .fill
        balanceStackView.distribution = .fillProportionally
        balanceStackView.addArrangedSubviews([balanceNameLabel, balanceCurrencyLabel])
        
        balanceContentView.addSubview(balanceStackView)
        balanceStackView.autoAlignAxis(toSuperviewAxis: .vertical)

        if dataModel.transaction.symbol == Config.defaultSymbol {
            balanceContentView.addSubview(communLogoImageView)
            communLogoImageView.autoPinEdge(toSuperviewEdge: .top, withInset: CGFloat.adaptive(height: 20.0))
            communLogoImageView.autoAlignAxis(toSuperviewAxis: .vertical)
            balanceStackView.autoPinEdge(.top, to: .bottom, of: communLogoImageView, withOffset: CGFloat.adaptive(height: 20.0))
        } else {
            balanceContentView.addSubview(carouselView)
            carouselView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: CGFloat.adaptive(width: 64.0), vertical: CGFloat.adaptive(height: 20.0)), excludingEdge: .bottom)

            balanceStackView.autoPinEdge(.top, to: .bottom, of: carouselView, withOffset: CGFloat.adaptive(height: 20.0))
        }
        
        updateRecipientInfo()
        updateBalanceInfo()
        dataModel.transaction.history == nil ? updateSendInfoByEnteredPoints() : updateSendInfoByHistory()

        // Action view
        let whiteView = UIView(width: CGFloat.adaptive(width: 375.0), height: CGFloat.adaptive(height: 543.0), backgroundColor: .white, cornerRadius: CGFloat.adaptive(width: 25.0))
        view.addSubview(whiteView)
        whiteView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
                
        let firstBorderView = UIView(width: CGFloat.adaptive(width: 345.0), height: CGFloat.adaptive(height: 70.0), backgroundColor: .white, cornerRadius: CGFloat.adaptive(width: 10.0))
        setup(borderedView: firstBorderView)
        whiteView.addSubview(firstBorderView)
        firstBorderView.autoPinTopAndLeadingToSuperView(inset: CGFloat.adaptive(height: 20.0), xInset: CGFloat.adaptive(width: 15.0))
        firstBorderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseRecipientViewTapped)))
        firstBorderView.isUserInteractionEnabled = true

        let recipientStackView = UIStackView(axis: .horizontal, spacing: CGFloat.adaptive(width: 10.0))
        recipientStackView.alignment = .leading
        recipientStackView.distribution = .fill

        recipientStackView.addArrangedSubviews([recipientAvatarImageView, recipientNameLabel, chooseRecipientButton])
        recipientNameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        chooseRecipientButton.autoAlignAxis(toSuperviewAxis: .horizontal)

        firstBorderView.addSubview(recipientStackView)
        recipientStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: CGFloat.adaptive(width: 30.0), vertical: CGFloat.adaptive(height: 30.0)))
        
        let secondBorderView = UIView(width: CGFloat.adaptive(width: 345.0), height: CGFloat.adaptive(height: 64.0), backgroundColor: .white, cornerRadius: CGFloat.adaptive(width: 10.0))
        setup(borderedView: secondBorderView)
        whiteView.addSubview(secondBorderView)
        secondBorderView.autoPinTopAndTrailingToSuperView(inset: CGFloat.adaptive(height: 100.0), xInset: CGFloat.adaptive(width: 15.0))
        
        let amountStackView = UIStackView(axis: .vertical, spacing: CGFloat.adaptive(height: 8.0))
        amountStackView.alignment = .fill
        amountStackView.distribution = .fillProportionally
        
        let amountLabel = UILabel()
        amountLabel.tune(withText: "amount".localized().uppercaseFirst,
                         hexColors: grayishBluePickers,
                         font: .systemFont(ofSize: CGFloat.adaptive(width: 12.0), weight: .semibold),
                         alignment: .left,
                         isMultiLines: false)
        
        amountStackView.addArrangedSubviews([amountLabel, pointsTextField])
        pointsTextField.inputAccessoryView = pointsToolbar

        secondBorderView.addSubview(amountStackView)
        amountStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: CGFloat.adaptive(width: 30.0), vertical: CGFloat.adaptive(height: 22.0)))
        
        secondBorderView.addSubview(clearPointsButton)
        clearPointsButton.autoPinTopAndTrailingToSuperView(inset: CGFloat.adaptive(height: 20.0), xInset: CGFloat.adaptive(width: 15.0))
        
        whiteView.addSubview(sendPointsButton)
        sendPointsButton.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(horizontal: CGFloat.adaptive(width: 30.0), vertical: CGFloat.adaptive(height: 20.0)), excludingEdge: .top)
    }
    
    
    // MARK: - Custom Functions
    private func setupNavBar() {
        title = "send points".localized()
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func setup(borderedView: UIView) {
        borderedView.translatesAutoresizingMaskIntoConstraints = false
        borderedView.layer.borderColor = UIColor.e2e6e8.cgColor
        borderedView.layer.borderWidth = 1.0
        borderedView.clipsToBounds = true
    }
    
    private func setSendButton(amount: CGFloat = 0.0, percent: CGFloat) {
        let subtitle1 = String(format: "%@: %@ %@", "send".localized().uppercaseFirst, Double(amount).currencyValueFormatted, dataModel.transaction.symbol.fullName)
        let subtitle2 = String(format: "%.1f%% %@", percent, "will be burned".localized())
        let title = NSMutableAttributedString(string: "\(subtitle1)\n\(subtitle2)")

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.paragraphSpacingBefore = CGFloat.adaptive(height: 1.0)
        style.paragraphSpacing = CGFloat.adaptive(height: 1.0)
        
        title.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat.adaptive(width: 15.0), weight: .bold),
                             NSAttributedString.Key.foregroundColor: UIColor.white,
                             NSAttributedString.Key.paragraphStyle: style
                            ], range: NSRange(location: 0, length: subtitle1.count))

        title.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat.adaptive(width: 12.0), weight: .semibold),
                             NSAttributedString.Key.foregroundColor: UIColor(hexString: "#ffffff", transparency: 0.7)!,
                             NSAttributedString.Key.paragraphStyle: style
                            ], range: NSRange(location: subtitle1.count + 1, length: subtitle2.count))

        sendPointsButton.setAttributedTitle(title, for: .normal)
        sendPointsButton.titleLabel?.lineBreakMode = .byWordWrapping
        sendPointsButton.titleLabel?.numberOfLines = 2
    }
    
    private func addGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    private func updateBalanceInfo() {
        let balance = dataModel.getBalance()
        balanceNameLabel.text = balance.name
        balanceCurrencyLabel.text = balance.amount == 0 ? "0" : Double(balance.amount).currencyValueFormatted
    }
    
    private func updateRecipientInfo() {
        chooseRecipientButton.isSelected = dataModel.transaction.recipient.name != nil

        if let recipientName = dataModel.transaction.recipient.name {
            recipientNameLabel.text = recipientName
            recipientAvatarImageView.setAvatar(urlString: dataModel.transaction.recipient.avatarURL, namePlaceHolder: recipientName)
        } else {
            recipientNameLabel.text = "select user".localized().uppercaseFirst
            recipientAvatarImageView = UIImageView.circle(size: CGFloat.adaptive(width: 40.0), imageName: "tux")
        }
    }

    private func updateSendInfoByHistory() {
        let amount = CGFloat(dataModel.transaction.history!.quantityValue)
        let accuracy = amount >= 1_000.0 ? 2 : 4

        setSendButton(amount: amount, percent: 0.1)
        pointsTextField.text = String(format: "%.*f", accuracy, amount)

        sendPointsButton.isEnabled = dataModel.checkHistoryAmounts() && chooseRecipientButton.isSelected
    }
    
    private func updateSendInfoByEnteredPoints() {
        guard let text = pointsTextField.text?.replacingOccurrences(of: ",", with: ".") else { return }
        
        let amountEntered = CGFloat((text as NSString).floatValue)
        dataModel.transaction.amount = amountEntered
        setSendButton(amount: amountEntered, percent: 0.1)
        pointsTextField.placeholder = String(format: "0 %@", dataModel.transaction.symbol.fullName)

        sendPointsButton.isEnabled = dataModel.checkEnteredAmounts() && chooseRecipientButton.isSelected
    }
    
    
    // MARK: - Actions
    @objc func chooseRecipientViewTapped(_ sender: UITapGestureRecognizer) {
        let friendsListVC = SendPointListVC { [weak self] recipient in
            guard let strongSelf = self else { return }
            
            strongSelf.dataModel.transaction.update(recipient: recipient)
            strongSelf.chooseRecipientButton.isSelected = true
            strongSelf.updateRecipientInfo()
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
        let numberValue = abs(dataModel.transaction.amount)

        guard let recipientID = dataModel.transaction.recipient.id, numberValue > 0 else { return }

        dataModel.transaction.operationDate = Date()

//        showIndetermineHudWithMessage("sending".localized().uppercaseFirst + " \(dataModel.transaction.symbol.fullName.uppercased())")

        // FOR TEST
        let completedVC = TransactionCompletedVC(transaction: dataModel.transaction)
        show(completedVC, sender: nil)

        /*
        BlockchainManager.instance.transferPoints(to: recipientID, number: Double(numberValue), currency: dataModel.transaction.symbol)
            .flatMapCompletable { RestAPIManager.instance.waitForTransactionWith(id: $0) }
            .subscribe(onCompleted: { [weak self] in
                guard let strongSelf = self else { return }

                let completedVC = TransactionCompletedVC(transaction: strongSelf.dataModel.transaction)
                strongSelf.show(completedVC, sender: nil)
                strongSelf.hideHud()
            }) { [weak self] error in
                guard let strongSelf = self else { return }
                
                strongSelf.hideHud()
                strongSelf.showError(error)
        }
        .disposed(by: disposeBag)
        */
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
        // TODO: - Add action
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            guard CharacterSet(charactersIn: "0123456789.,").isSuperset(of: CharacterSet(charactersIn: string)) || string.isEmpty else { return false }
            
            let countDots = (text + string).filter({$0 == "."}).count
            let countCommas = (text + string).filter({$0 == ","}).count
                
            guard countDots + countCommas <= 1 else { return false }

            if (text.hasSuffix(".") || text.hasSuffix(",")) && (string == "." || string == ",") {
                return false
            }
            
            clearPointsButton.isHidden = text.count == 1 && string.isEmpty
        }
                        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSendInfoByEnteredPoints()
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
        return dataModel.balances.firstIndex(where: { $0.symbol == dataModel.transaction.symbol }) ?? 0
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
        dataModel.transaction.symbol = dataModel.balances[index].symbol
        updateBalanceInfo()
        updateSendInfoByEnteredPoints()
    }
    
    func carousel(_ carousel: CircularCarousel, willBeginScrollingToIndex index: Int) {
        dataModel.transaction.symbol = dataModel.balances[index].symbol
    }
}
