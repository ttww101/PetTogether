//
//  searchTaskCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/27.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class SearchTaskCell: UITableViewCell {
    
    @IBOutlet weak var searchTaskView: TaskDetailInfoView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchTaskView.layer.cornerRadius = 23
//        searchTaskView.layer.borderWidth = 1
//        searchTaskView.layer.borderColor = #colorLiteral(red: 0.7450980392, green: 0.6588235294, blue: 0.6274509804, alpha: 1)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
 
}
