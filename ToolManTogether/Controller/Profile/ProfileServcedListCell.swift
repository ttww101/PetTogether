//
//  ProfileServcedListCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class ProfileServcedListCell: UITableViewCell {
    
    @IBOutlet weak var photoOne: UIImageView!
    @IBOutlet weak var photoTwo: UIImageView!
    @IBOutlet weak var photoThree: UIImageView!
    @IBOutlet weak var viewFour: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoOne.layer.cornerRadius = 10
        photoTwo.layer.cornerRadius = 10
        photoThree.layer.cornerRadius = 10
        viewFour.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
