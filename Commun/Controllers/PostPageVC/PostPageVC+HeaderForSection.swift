//
//  PostPageVC+UITableViewDataSource.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension PostPageVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .white
        
        let separator = UIView(frame: CGRect(x: 16, y: 0, width: self.view.bounds.width - 32, height: 0.5))
        separator.backgroundColor = #colorLiteral(red: 0.6078431373, green: 0.6235294118, blue: 0.6352941176, alpha: 1)
        header.addSubview(separator)
        
        let commentLabel = UILabel(frame: CGRect(x: 16, y: 14.5, width: self.view.bounds.width - 32, height: 27))
        commentLabel.font = UIFont(name: "SF Pro Text", size: 22)
        commentLabel.text = "Comments"
        header.addSubview(commentLabel)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 50
    }
    
}
