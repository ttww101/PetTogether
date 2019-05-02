//
//  TaskContentCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/16.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class TaskContentCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTxtView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
