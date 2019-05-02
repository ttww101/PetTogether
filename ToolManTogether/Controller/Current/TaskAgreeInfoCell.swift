//
//  TaskAgreeInfoCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

protocol CallBtnTapped: AnyObject {
    func callBtnTapped (_ send: UIButton)
    func messageBtnTapped (_ send: UIButton)
}

class TaskAgreeInfoCell: UITableViewCell {

    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    weak var callBtnDelegate: CallBtnTapped?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callBtn.layer.cornerRadius = 10
        messageBtn.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func callBtnTapped(_ sender: Any) {
        callBtnDelegate?.callBtnTapped(self.callBtn)
    }
    
    @IBAction func messageBtnTapped(_ sender: Any) {
        callBtnDelegate?.messageBtnTapped(self.messageBtn)
    }
}
