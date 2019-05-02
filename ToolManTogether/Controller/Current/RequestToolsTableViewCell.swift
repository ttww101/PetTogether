//
//  RequestToolsTableViewCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/29.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func tableViewCellDidTapAgreeBtn(_ send: RequestToolsTableViewCell)
}

class RequestToolsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userContentTxtView: UITextView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var starOne: UIButton!
    @IBOutlet weak var starTwo: UIButton!
    @IBOutlet weak var starThree: UIButton!
    @IBOutlet weak var starFour: UIButton!
    @IBOutlet weak var starFive: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    weak var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userPhoto.layer.cornerRadius = userPhoto.frame.width / 2
        agreeButton.layer.cornerRadius = 10
        agreeButton.layer.shadowColor = UIColor.darkGray.cgColor
        agreeButton.layer.shadowRadius = 3
        agreeButton.layer.shadowOpacity = 0.5
        agreeButton.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func agreeTapped(_ sender: Any) {
        delegate?.tableViewCellDidTapAgreeBtn(self)
    }
}
