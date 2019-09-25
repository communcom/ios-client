//
//  PostPageVC+HeaderForSection.swift
//  Commun
//
//  Created by Chung Tran on 9/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostPageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        
        // Comments title
        let commentTitle = UILabel(frame: .zero)
        commentTitle.font = .boldSystemFont(ofSize: 21)
        commentTitle.text = "comments".localized().uppercaseFirst
        commentTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(commentTitle)
        
        commentTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        commentTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Sort button
        let button = UIButton(frame: .zero)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 18)
        button.setTitleColor(.appMainColor, for: .normal)
        #warning("sorting")
        button.setTitle("interesting first".localized().uppercaseFirst, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Down arrow image
        let imageView = UIImageView(image: UIImage(named: "small-down-arrow"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
