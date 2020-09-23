//
//  CMSendPointsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/22/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class CMTransferVC: BaseViewController, UITextFieldDelegate {
    // MARK: - Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {.lightContent}
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.normal(translucent: true, backgroundColor: .clear, font: .boldSystemFont(ofSize: 17), textColor: .appWhiteColor)}
    override var shouldHideTabBar: Bool {true}
    var topColor: UIColor { .appMainColor }
    var titleText: String { "convert".localized().uppercaseFirst }
    
    // MARK: - Subviews
    lazy var scrollView: ContentHuggingScrollView = {
        let scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
        scrollView.contentView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.contentView.addGestureRecognizer(tap)
        return scrollView
    }()
    lazy var topStackView: UIStackView = {
        let stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .center, distribution: .fill)
        stackView.addArrangedSubviews([balanceNameLabel, valueLabel])
        stackView.setCustomSpacing(5, after: balanceNameLabel)
        return stackView
    }()
    lazy var balanceNameLabel = UILabel.with(text: "CMN", textSize: 17, weight: .semibold, textColor: .white)
    lazy var valueLabel = UILabel.with(text: "0.0000", textSize: 30, weight: .semibold, textColor: .white)
    lazy var whiteView = UIView(backgroundColor: .appWhiteColor)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    lazy var actionButton: CommunButton = {
        let button = CommunButton.default(height: 50, label: "convert".localized().uppercaseFirst, isHuggingContent: false, isDisabled: true)
        button.addTarget(self, action: #selector(actionButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBarBackButton(tintColor: .white)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
    override func setUp() {
        super.setUp()
        // backgroundColor
        let topView = UIView(backgroundColor: topColor)
        view.addSubview(topView)
        topView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        // scroll view
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        
        // top scrollView
        scrollView.contentView.addSubview(topStackView)
        topStackView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        topStackView.autoAlignAxis(toSuperviewAxis: .vertical)

        scrollView.contentView.addSubview(whiteView)
        whiteView.autoPinEdge(.top, to: .bottom, of: topStackView, withOffset: 40)
        whiteView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        whiteView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 40, left: 16, bottom: 0, right: 16))
        
        // config topView
        topView.autoPinEdge(.bottom, to: .top, of: whiteView, withOffset: 25)
        
        // action button
        view.addSubview(actionButton)
        actionButton.autoPinEdge(.top, to: .bottom, of: scrollView)
        actionButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        actionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        actionButton.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 16)
    }
    
    override func bind() {
        super.bind()
        bindScrollView()
    }
    
    // MARK: - Actions
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func actionButtonDidTouch() {
        view.endEditing(true)
    }
    
    func bindScrollView() {
        let keyboardOnOffset: CGFloat = 161.5
        var additionalBottomInset: CGFloat?
        switch UIDevice.current.screenType {
        case .iPhones_6_6s_7_8:
            additionalBottomInset = 51
        case .iPhones_6Plus_6sPlus_7Plus_8Plus:
            additionalBottomInset = 110.5
        case .iPhones_X_XS, .iPhone_11Pro:
            additionalBottomInset = 97.5
        case .iPhone_XR_11:
            additionalBottomInset = 171
        case .iPhone_XSMax_ProMax:
            additionalBottomInset = 171.5
        case .unknown:
            break
        default:
            break
        }
        
        // handle keyboard
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe { _ in
                DispatchQueue.main.async {
                    if let additionalBottomInset = additionalBottomInset {
                        self.scrollView.contentInset.bottom = additionalBottomInset
                    }
                    let bottomOffset = CGPoint(x: 0, y: keyboardOnOffset)
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
            .subscribe { _ in
                DispatchQueue.main.async {
                    let bottomOffset = CGPoint(x: 0, y: keyboardOnOffset)
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification)
            .subscribe { _ in
                if additionalBottomInset != nil {
                    self.scrollView.contentInset.bottom = 0
                }
            }
            .disposed(by: disposeBag)
        
        scrollView.rx.contentOffset
            .map {$0.y}
            .subscribe(onNext: { (offsetY) in
                    
                let titleLabel = UILabel.with(text: self.titleText, textSize: 15, weight: .semibold, textColor: .white, numberOfLines: 2, textAlignment: .center)
                
                if offsetY >= self.view.safeAreaInsets.top + CGFloat.adaptive(height: 6) {
                    if offsetY >= self.view.safeAreaInsets.top + CGFloat.adaptive(height: 33) {
                        titleLabel.attributedText = NSMutableAttributedString()
                            .text(self.balanceNameLabel.text ?? "", size: 14, weight: .semibold, color: .white)
                            .text("\n")
                            .text(self.valueLabel.text ?? "", size: 16, weight: .semibold, color: .white)
                        self.balanceNameLabel.alpha = 0
                        self.valueLabel.alpha = 0
                    } else {
                        titleLabel.text = self.balanceNameLabel.text
                        self.balanceNameLabel.alpha = 0
                        self.valueLabel.alpha = 1
                    }
                } else {
                    self.balanceNameLabel.alpha = 1
                    self.valueLabel.alpha = 1
                }
                self.navigationItem.titleView = titleLabel
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    func createTextField() -> UITextField {
        let textField = UITextField(backgroundColor: .clear)
        textField.placeholder = "0"
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 17, weight: .semibold)
        textField.setPlaceHolderTextColor(.appGrayColor)
        textField.keyboardType = .decimalPad
        textField.delegate = self
        return textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // if input comma (or dot)
        if textField.text?.isEmpty == true, string == Locale.current.decimalSeparator {
            textField.text = "0\(Locale.current.decimalSeparator ?? ".")"
            return false
        }
        
        // if deleting
        if string.isEmpty { return true }
        
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // check if newText is a Number
        let formatter = NumberFormatter()
        let isANumber = formatter.number(from: updatedText) != nil
        
        if updatedText.starts(with: "0") && !updatedText.starts(with: "0\(Locale.current.decimalSeparator ?? ".")") {
            updatedText = currentText.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
            textField.text = updatedText
        }
        
        return isANumber
    }
    
    // MARK: - View builder
    func borderedView() -> UIView {
        let view = UIView(cornerRadius: 10)
        view.borderColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1).inDarkMode(.white)
        view.borderWidth = 1
        return view
    }
}
