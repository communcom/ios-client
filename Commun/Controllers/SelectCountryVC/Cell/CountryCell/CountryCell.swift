//
//  CountryCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import SDWebImage

class CountryCell: UITableViewCell {

    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        countryImage.layer.cornerRadius = countryImage.height / 2
        countryImage.clipsToBounds = true
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCountry(_ country: Country) {
        countryImage.sd_setImage(with: country.flagURL, completed: nil)
        countryLabel.text = "\(country.localizedName) (\(country.phoneCode))"
    }
}
