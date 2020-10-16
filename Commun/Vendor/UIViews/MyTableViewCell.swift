//
//  TableViewCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift

class MyTableViewCell: UITableViewCell {
    // MARK: - Constants
    
    // MARK: - Properties
    var roundedCorner: UIRectCorner = [] {
        didSet {
            layoutSubviews()
        }
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func setUpViews() {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners()
    }
    
    func roundCorners() {
        roundCorners(roundedCorner, radius: 10)
    }
    
    @discardableResult
    func configureToUseAsNormalView() -> Self {
        setUpViews()
        contentView.configureForAutoLayout()
        contentView.autoPinEdgesToSuperviewEdges()
        return self
    }
}
