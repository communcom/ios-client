//
//  CountryCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import SDWebImage

class CountryCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var countryImage: UIImageView! {
        didSet {
            self.countryImage.layer.cornerRadius = 42.0 * Config.heightRatio / 2.0
            self.countryImage.layer.borderColor = UIColor.init(hexString: "#E2E6E8")!.cgColor
            self.countryImage.layer.borderWidth = 1.0
            self.countryImage.clipsToBounds = true
        }
    }
       
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            self.stackView.spacing = 16.0 * Config.widthRatio
        }
    }
    
    
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
        self.countryImage.sd_setImage(with: country.flagURL, completed: nil)
        self.countryLabel.text = "\(country.localizedName) (\(country.phoneCode))"
    }
}
