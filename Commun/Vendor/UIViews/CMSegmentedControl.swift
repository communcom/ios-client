//
//  CMSegmentedControl.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CMSegmentedControl: MyView {
    // MARK: - Nested type
    class TapGesture: UITapGestureRecognizer {
        var index = 0
    }
    
    struct Item {
        var name: String
    }
    
    // MARK: - Properties
    var labels: [UILabel]!
    var items: [Item]! {
        didSet {
            // clean
            if labels != nil {
                labels.forEach {$0.removeFromSuperview()}
            }
            labels = [UILabel]()
            
            stackView.removeArrangedSubviews()
            
            // setup label
            for i in 0..<items.count {
                let label = UILabel.with(text: items[i].name, textSize: 15, weight: .bold)
                
                label.textAlignment = .center
                label.isUserInteractionEnabled = true
                let tap = TapGesture(target: self, action: #selector(changeSelection(_:)))
                tap.index = i
                label.addGestureRecognizer(tap)
                
                stackView.addArrangedSubview(label)
                labels.append(label)
            }
        }
    }
    let selectedIndex = BehaviorRelay<Int>(value: 0)
    let bag = DisposeBag()
    
    // MARK: - Subviews
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var indicatorView: UIView = {
        let view = UIView(width: 16, height: 2)
        view.cornerRadius = 1
        view.backgroundColor = .appMainColor
        return view
    }()
    
    // MARK: - Init
    override func commonInit() {
        super.commonInit()
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
        
        addSubview(indicatorView)
        indicatorView.autoPinEdge(.top, to: .bottom, of: stackView)
        indicatorView.autoPinEdge(toSuperviewEdge: .bottom)
        
        selectedIndex
            .skip(1)
            .subscribe(onNext: { (index) in
                self.setUp()
            })
            .disposed(by: bag)
    }
    
    func setUp() {
        if selectedIndex.value >= items.count {return}
        
        for i in 0..<labels.count {
            labels[i].textColor = (selectedIndex.value == i) ? .black : UIColor(hexString: "#A5A7BD")
        }
        
        // remove constraint
        let multiplier: CGFloat = CGFloat(CGFloat(2 * selectedIndex.value + 1) / CGFloat(labels.count))
        
        indicatorView.removeConstraintToSuperView(withAttribute: .centerX)
        
        // move indicator
        NSLayoutConstraint(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: stackView, attribute: .centerX, multiplier: multiplier, constant: 0).isActive = true
           
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
    }
    
    @objc private func changeSelection(_ sender: TapGesture) {
        changeSelectedIndex(sender.index)
    }
    
    func changeSelectedIndex(_ index: Int) {
        if index == selectedIndex.value {return}
        selectedIndex.accept(index)
    }
}
