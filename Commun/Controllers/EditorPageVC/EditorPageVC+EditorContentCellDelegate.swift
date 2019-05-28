//
//  EditorPageVC+EditorContentCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 04/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension EditorPageVC: EditorContentCellDelegate {

    func contentCell(_ cell: EditorContentCell, didChangeText text: String) {
        viewModel?.contentText.accept(text)
    }

}
