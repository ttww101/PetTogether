//
//  AddTaskContentCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class AddTaskContentCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var contentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentTextView.delegate = self
        contentTextView.setContentOffset(CGPoint.zero, animated: false)
        
        contentTextView.clipsToBounds = false
        contentTextView.layer.shadowColor = UIColor.darkGray.cgColor
        contentTextView.layer.cornerRadius = 10
        contentTextView.layer.shadowRadius = 1
        contentTextView.layer.shadowOpacity = 0.5
        contentTextView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        let claneDataNotification = Notification.Name("addTask")
        NotificationCenter.default.addObserver(self, selector: #selector(self.cleanData), name: claneDataNotification, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func cleanData() {
        contentTextView.text = ""
    }
    
}
