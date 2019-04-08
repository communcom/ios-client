//
//  EditorContentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 02/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol EditorContentCellDelegate {
    func contentCell(_ cell: EditorContentCell, didChangeText text: String)
}

class EditorContentCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    var delegate: EditorContentCellDelegate?
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        textView.placeholder = "Enter text..."
        
        textView.rx.text.subscribe(onNext: { [weak self] text in
            if let self = self {
                self.delegate?.contentCell(self, didChangeText: text ?? "")
            }
        }).disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
