//
//  FeedPageVC+UITableViewDataSource.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension FeedPageVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "PostCardCell") as! UITableViewCell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "PostCardMediaCell") as! UITableViewCell
        }
    }
    
}
