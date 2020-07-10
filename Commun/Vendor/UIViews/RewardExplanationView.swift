//
//  PostRewardExplanationView.swift
//  Commun
//
//  Created by Chung Tran on 7/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

protocol RewardExplanationViewDelegate: class {
    func rewardExplanationViewDidTapOnShowInDropdown(_ rewardExplanationView: RewardExplanationView)
}

class RewardExplanationView: MyView {
    let params: CMCardViewParameters
    let disposeBag = DisposeBag()
    weak var delegate: RewardExplanationViewDelegate?
    
    lazy var swipeDownButton = UIView(width: 50, height: 5, backgroundColor: .appWhiteColor, cornerRadius: 2.5)
    lazy var showingOptionButtonLabel = UILabel.with(text: "community points".localized().uppercaseFirst, textColor: .appGrayColor)
    lazy var showingOptionButton: UIStackView = {
        let view = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        let dropdownButton = UIButton.circleGray(imageName: "drop-down")
        dropdownButton.isUserInteractionEnabled = false
        view.addArrangedSubviews([showingOptionButtonLabel, dropdownButton])
        return view
    }()
    lazy var explanationView = UserNameRulesView(withFrame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 355.0), height: .adaptive(height: 193.0))), andParameters: params)
    
    init(params: CMCardViewParameters) {
        self.params = params
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .clear
        explanationView.backgroundColor = .appWhiteColor
        explanationView.cornerRadius = 25
        
        let stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .center, distribution: .fill)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let showInView = UIView(height: 50, backgroundColor: .appWhiteColor, cornerRadius: 25)
        let showInLabel = UILabel.with(text: "show in".localized().uppercaseFirst)
        showInView.addSubview(showInLabel)
        showInLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), excludingEdge: .trailing)
        showInView.addSubview(showingOptionButton)
        showingOptionButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), excludingEdge: .leading)
        showInLabel.autoPinEdge(.trailing, to: .leading, of: showingOptionButton, withOffset: 10)
        
        stackView.addArrangedSubviews([swipeDownButton, showInView, explanationView])
        
        showInView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        explanationView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        swipeDownButton.isUserInteractionEnabled = true
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownButtonDidTouch(_:)))
        gesture.direction = .down
        swipeDownButton.addGestureRecognizer(gesture)
        
        showingOptionButton.isUserInteractionEnabled = true
        showingOptionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showInDropdownDidTouch)))
        
        UserDefaults.standard.rx.observe(String.self, Config.currentRewardShownSymbol)
            .subscribe(onNext: { (symbol) in
                let symbol = symbol ?? "community points"
                self.showingOptionButtonLabel.text = symbol.localized().uppercaseFirst
            })
            .disposed(by: disposeBag)
    }
    
    @objc func swipeDownButtonDidTouch(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            parentViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func showInDropdownDidTouch() {
        delegate?.rewardExplanationViewDidTapOnShowInDropdown(self)
    }
}
