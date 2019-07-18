//
//  SettingsVC+SectionHeader.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1, 2:
            return 56
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel(frame: CGRect(x: 16, y: 15, width: self.view.frame.width, height: 30))

        switch section {
        case 0:
            label.text = "General".localized()
            break

        case 1:
            label.text = "Notifications".localized()
            break

        case 2:
            label.text = "Passwords".localized()
            break

        default:
            label.text = ""
        }

        label.font = .boldSystemFont(ofSize: 22)
        view.addSubview(label)

        return view
    }
}
