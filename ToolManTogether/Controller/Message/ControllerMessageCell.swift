//
//  ControllerMessageCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/24.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class ControllerMessageCell: UITableViewCell {
    
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var taskType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.textColor = UIColor.darkGray
        taskType.layer.cornerRadius = 10
        taskType.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
