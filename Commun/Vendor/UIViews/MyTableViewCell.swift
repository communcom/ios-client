//
//  TableViewCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class MyTableViewCell: UITableViewCell {
    // MARK: - Constants
    var disposeBag = DisposeBag()
    
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
        observe()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // http://adamborek.com/top-7-rxswift-mistakes/
        // have to reset disposeBag when reusing cell
        disposeBag = DisposeBag()
        observe()
    }
    
    func observe() {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(roundedCorner, radius: 10)
    }
}
