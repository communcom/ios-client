//
//  CommunitiesVC+DataSource.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension CommunitiesVC: UITableViewDelegate {
    typealias Section = AnimatableSectionModel<String, MockupCommunity>
    
    var dataSource: RxTableViewSectionedAnimatedDataSource<Section> {
        return RxTableViewSectionedAnimatedDataSource<Section>(
            configureCell: { dataSource, tableView, indexPath, community -> CommunityCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell", for: indexPath) as! CommunityCell
                cell.setUp(community: community)
                return cell
            }
        )
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Hide "My community" header
        if section == 1 {return 0}
        
        // Hide "Recommended" when "My communities" is showing
        if viewModel.filter.value.joined == true {return 0}
        
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // create view
        let view = UIView()
        view.backgroundColor = .white
        
        // create uilabel
        let label = UILabel(text: section == 0 ? "Recommended".localized(): nil)
        label.font = .boldSystemFont(ofSize: 22)
        view.addSubview(label)
        
        // constraint
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        return view
    }
}
