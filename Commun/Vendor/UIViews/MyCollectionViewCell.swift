//
//  MyCollectionViewCell.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class MyCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        setUpViews()
    }
}
