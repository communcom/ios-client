//
//  CountryCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import CyberSwift
import SDWebImage

class CountryCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var countryLabel: UILabel!

    @IBOutlet weak var flagLabel: UILabel!

    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: - Class Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    // MARK: - Class Functions
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Custom Functions
    func setupCountry(_ country: Country) {
        countryLabel.text = "\(country.name) (+\(country.code))"
        flagLabel.text = country.emoji
        countryLabel.textColor = country.available ? .appBlackColor : .appGrayColor
    }
    
    func setUpLanguage(_ country: Country) {
        flagLabel.text = country.emoji
        countryLabel.attributedString = NSMutableAttributedString()
            .text(country.name, size: 15, weight: .medium)
            .text("\n")
            .text(country.language?.name ?? country.language?.code ?? "", size: 12, weight: .semibold, color: .appGrayColor)
    }
}
