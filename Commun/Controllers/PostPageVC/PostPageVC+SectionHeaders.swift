//
//  PostPageVC+SectionHeaders.swift
//  Commun
//
//  Created by Chung Tran on 20/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostPageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let header = UIButton(type: .system)
        header.setTitle("Load more comments".localized() + "...", for: .normal)
        
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        header.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        header.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        return view

    }
}
