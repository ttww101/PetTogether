//
//  AddTaskTypeCollectionViewCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

protocol TypeBtnPressed: AnyObject {
    func typeSelect(_ cell: UICollectionViewCell)
}

class AddTaskTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeButtonView: UIView!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var underLineView: UIView!
    
    weak var typeDelegate: TypeBtnPressed?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeButton.layer.cornerRadius = 10
        typeButton.layoutIfNeeded()
    }

    @IBAction func typeBtnPressed(_ sender: Any) {
        typeDelegate?.typeSelect(self)
    }
}
