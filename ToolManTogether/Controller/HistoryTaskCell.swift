//
//  HistoryTaskCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/28.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class HistoryTaskCell: UITableViewCell {
    
    @IBOutlet weak var historyView: TaskDetailInfoView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        historyView.separatorView.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
