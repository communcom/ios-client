//
//  BuyCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 1/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class BuyCommunVC: BaseViewController {
    // MARK: - Properties
    lazy var viewModel = BuyCommunViewModel()
    var currentCurrencyName: String? {
        viewModel.currentCurrency.value?.name.uppercased()
    }
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(axis: .vertical)
    lazy var currencyAvatarImageView = MyAvatarImageView(size: 40)
    lazy var currencyNameLabel = UILabel.with(textSize: 15, weight: .medium)
    lazy var youSendTextField = UITextField.decimalPad()
    lazy var minimunChargeLabel = UILabel.with(text: "minimum charge is".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd)
    lazy var youGetTextField = UITextField.decimalPad()
    lazy var rateLabel = UILabel.with(text: "Rate:", textSize: 12, weight: .medium, textColor: .a5a7bd, textAlignment: .center)
    lazy var buyCommunButton = CommunButton.default(height: 50, label: "buy Commun".localized().uppercaseFirst, cornerRadius: 25, isHuggingContent: false, isDisableGrayColor: true)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "buy Commun".localized().uppercaseFirst
        view.backgroundColor = .f3f5fa
        
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea()
        
        let youSendLabel = UILabel.with(text: "you send".localized().uppercaseFirst, textSize: 15, weight: .medium)
        scrollView.contentView.addSubview(youSendLabel)
        youSendLabel.autoPinTopAndLeadingToSuperView(inset: 20, xInset: 26)
        
        // currency container
        let youSendContainerView: UIView = {
            let view = UIView(backgroundColor: .white, cornerRadius: 10)
            view.addSubview(self.currencyAvatarImageView)
            self.currencyAvatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            self.currencyAvatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
            
            view.addSubview(self.currencyNameLabel)
            self.currencyNameLabel.autoPinEdge(.leading, to: .trailing, of: self.currencyAvatarImageView, withOffset: 10)
            self.currencyNameLabel.autoAlignAxis(.horizontal, toSameAxisOf: self.currencyAvatarImageView)
            
            let dropdownButton = UIButton.circleGray(imageName: "drop-down")
            view.addSubview(dropdownButton)
            dropdownButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            dropdownButton.autoAlignAxis(.horizontal, toSameAxisOf: self.currencyAvatarImageView)
            
            let separator = UIView(height: 2, backgroundColor: .f3f5fa)
            view.addSubview(separator)
            separator.autoPinEdge(.top, to: .bottom, of: self.currencyAvatarImageView, withOffset: 16)
            separator.autoPinEdge(toSuperviewEdge: .leading)
            separator.autoPinEdge(toSuperviewEdge: .trailing)
            
            let amountLabel = UILabel.with(text: "amount".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd)
            view.addSubview(amountLabel)
            amountLabel.autoPinEdge(.top, to: .bottom, of: separator, withOffset: 10)
            amountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            
            view.addSubview(self.youSendTextField)
            self.youSendTextField.autoPinEdge(.top, to: .bottom, of: amountLabel, withOffset: 8)
            self.youSendTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
            
            return view
        }()
        
        scrollView.contentView.addSubview(youSendContainerView)
        youSendContainerView.autoPinEdge(.top, to: .bottom, of: youSendLabel, withOffset: 10)
        youSendContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        youSendContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        scrollView.contentView.addSubview(minimunChargeLabel)
        minimunChargeLabel.autoPinEdge(.top, to: .bottom, of: youSendContainerView, withOffset: 5)
        minimunChargeLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 32)
        
        let youGetLabel = UILabel.with(text: "you get".localized().uppercaseFirst, textSize: 15, weight: .medium)
        scrollView.contentView.addSubview(youGetLabel)
        youGetLabel.autoPinEdge(.top, to: .bottom, of: minimunChargeLabel, withOffset: 20)
        youGetLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 25)
        
        let youGetContainerView: UIView = {
            let view = UIView(backgroundColor: .white, cornerRadius: 10)
            
            let communLogo = UIImageView(width: 40, height: 40, cornerRadius: 20, imageNamed: "tux")
            view.addSubview(communLogo)
            communLogo.autoPinTopAndLeadingToSuperView(inset: 16)
            
            let communLabel = UILabel.with(text: "Commun", textSize: 15, weight: .medium)
            view.addSubview(communLabel)
            communLabel.autoPinEdge(.leading, to: .trailing, of: communLogo, withOffset: 10)
            communLabel.autoAlignAxis(.horizontal, toSameAxisOf: communLogo)
            
            let separator = UIView(height: 2, backgroundColor: .f3f5fa)
            view.addSubview(separator)
            separator.autoPinEdge(.top, to: .bottom, of: communLogo, withOffset: 16)
            separator.autoPinEdge(toSuperviewEdge: .leading)
            separator.autoPinEdge(toSuperviewEdge: .trailing)
            
            view.addSubview(self.youGetTextField)
            youGetTextField.autoPinEdge(.top, to: .bottom, of: separator, withOffset: 22)
            youGetTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 22, left: 16, bottom: 22, right: 16), excludingEdge: .top)
            return view
        }()
        
        scrollView.contentView.addSubview(youGetContainerView)
        youGetContainerView.autoPinEdge(.top, to: .bottom, of: youGetLabel, withOffset: 16)
        youGetContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        youGetContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        scrollView.contentView.addSubview(rateLabel)
        rateLabel.autoPinEdge(.top, to: .bottom, of: youGetContainerView, withOffset: 10)
        rateLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        rateLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        let changeHeroView: UIView = {
            let view = UIView(backgroundColor: .white, cornerRadius: 10)
            let imageView = UIImageView(width: 50, height: 50, imageNamed: "changeHeroLogo")
            view.addSubview(imageView)
            imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: 16, vertical: 10), excludingEdge: .trailing)
            
            let label = UILabel.with(textSize: 15, numberOfLines: 0)
            
            label.attributedText = NSMutableAttributedString()
                .text("the purchase is made by".localized().uppercaseFirst, size: 12, weight: .medium, color: .a5a7bd)
                .normal("\n")
                .text("Change Hero", size: 15, weight: .semibold)
            
            view.addSubview(label)
            label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            let questionMark = UIImageView(width: 30, height: 30, cornerRadius: 15, imageNamed: "question")
            view.addSubview(questionMark)
            questionMark.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            questionMark.autoAlignAxis(.horizontal, toSameAxisOf: imageView)
            questionMark.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 10)
            
            return view
        }()
        
        scrollView.contentView.addSubview(changeHeroView)
        changeHeroView.autoPinEdge(.top, to: .bottom, of: rateLabel, withOffset: 70 * Config.heightRatio)
        changeHeroView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        changeHeroView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        let termsOfUseLabel = UILabel.with(textSize: 15, numberOfLines: 2, textAlignment: .center)
        let aStr = NSMutableAttributedString()
            .text("by clicking convert, you agree to ChangeHero's terms of service.".localized().uppercaseFirst, size: 12, weight: .medium, color: .a5a7bd)
        termsOfUseLabel.attributedText = aStr.applying(attributes: [.foregroundColor: UIColor.appMainColor], toOccurrencesOf: "terms of service.".localized())
        
        scrollView.contentView.addSubview(termsOfUseLabel)
        termsOfUseLabel.autoPinEdge(.top, to: .bottom, of: changeHeroView, withOffset: 18)
        termsOfUseLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        termsOfUseLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        scrollView.contentView.addSubview(buyCommunButton)
        buyCommunButton.autoPinEdge(.top, to: .bottom, of: termsOfUseLabel, withOffset: 16)
        
        buyCommunButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
    }
    
    override func bind() {
        super.bind()
        // loading state
        viewModel.loadingState
            .subscribe(onNext: { (state) in
                switch state {
                case .loading:
                    self.scrollView.showLoader()
                case .finished:
                    self.scrollView.hideLoader()
                case .error(let error):
                    #if !APPSTORE
                    self.showError(error)
                    #endif
                    self.scrollView.hideLoader()
                    self.view.showErrorView {
                        self.view.hideErrorView()
                        self.viewModel.currenciesVM.reload()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // current currency
        viewModel.currentCurrency
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { [weak self] (currency) in
                self?.setUpWithCurrentCurrency(currency)
            })
            .disposed(by: disposeBag)
        
        // min max amount
        viewModel.minMaxAmount
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { [weak self] (amount) in
                // minimun charge
                self?.minimunChargeLabel.text = "minimum charge is".localized().uppercaseFirst + " \((Double(amount.minFromAmount) ?? 0).currencyValueFormatted) " + (self?.currentCurrencyName ?? "")
            })
            .disposed(by: disposeBag)
        
        // price
        viewModel.price
            .subscribe(onNext: { [weak self] (price) in
                var text = "rate".localized().uppercaseFirst
                text += ": 1 "
                text += (self?.currentCurrencyName ?? "")
                text += " = "
                text += price.currencyValueFormatted
                text += " CMN"
                self?.rateLabel.text = text
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpWithCurrentCurrency(_ currency: ResponseAPIGetCurrency) {
        // avatar
        currencyAvatarImageView.setAvatar(urlString: currency.image, namePlaceHolder: currency.name)
        
        // name
        currencyNameLabel.text = currency.name.uppercased()
    }
}
