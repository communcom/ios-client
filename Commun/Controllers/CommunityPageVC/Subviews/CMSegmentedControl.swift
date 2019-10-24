//
//  CMSegmentedControl.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class CMSegmentedControl: MyView {
    // MARK: - Nested type
    struct Item {
        var name: String
        var isActive = false
        fileprivate(set) var label: UILabel? = nil
    }
    
    // MARK: - Properties
    var items: [Item]!
    let selectedIndex = PublishSubject<Int>()
    
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
    }
    
    func setUp(with newItems: [Item]) {
        guard newItems.count > 0 else {return}
        
        items = newItems
        
        stackView.removeArrangedSubviews()
        
        // setup label
        var activeLabel: UILabel!
        for i in 0..<items.count {
            let label = UILabel.with(text: items[i].name, textSize: 15, weight: .bold, textColor: items[i].isActive ? .black: UIColor(hexString: "#A5A7BD")!)
            label.textAlignment = .center
            items[i].label = label
            stackView.addArrangedSubview(label)
            if items[i].isActive {
                activeLabel = label
            }
        }
        
        // remove constraint
        if let centerXConstraint = indicatorView.constraints.first(where: {$0.firstAttribute == .centerX}) {
            indicatorView.removeConstraint(centerXConstraint)
        }
        
        // move indicator
        if let label = activeLabel {
            indicatorView.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        }

    }
}
