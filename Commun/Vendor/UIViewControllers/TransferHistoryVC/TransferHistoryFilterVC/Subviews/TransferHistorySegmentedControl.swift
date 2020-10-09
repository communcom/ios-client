//
//  TransferHistorySegmentedControl.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class TransferHistorySegmentedControl: MyView {
    // MARK: - Nested type
    class TapGesture: UITapGestureRecognizer {
        var index = 0
    }
    
    // MARK: - Properties
    var labels = [String]() {
        didSet {
            guard !labels.isEmpty else {return}
            
            stackView.removeArrangedSubviews()
            
            // setUp labels
            for i in 0..<labels.count {
                let label = UILabel.with(text: labels[i], textSize: 15, weight: .bold)
                label.textAlignment = .center
                label.isUserInteractionEnabled = true
                label.cornerRadius = 16
                let tap = TapGesture(target: self, action: #selector(changeSelection(_:)))
                tap.index = i
                label.addGestureRecognizer(tap)
                
                stackView.addArrangedSubview(label)
                label.autoPinEdge(toSuperviewEdge: .top)
                label.autoPinEdge(toSuperviewEdge: .bottom)
            }
        }
    }
    
    var selectedIndex = 0 {
        didSet {
            setUp()
        }
    }
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .horizontal)
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        cornerRadius = 16
        borderWidth = 1
        borderColor = .appLightGrayColor
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
    
    func setUp() {
        guard selectedIndex >= 0, selectedIndex < labels.count else {return}
        // reset state
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            view.backgroundColor = (index == selectedIndex) ? .appMainColor : .clear
            (view as! UILabel).textColor = (index == selectedIndex) ? .white : .appGrayColor
        }
    }
    
    @objc private func changeSelection(_ sender: TapGesture) {
        changeSelectedIndex(sender.index)
    }
    
    func changeSelectedIndex(_ index: Int) {
        if index == selectedIndex {return}
        selectedIndex = index
    }
}
