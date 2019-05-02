//
//  TaskDetailInfoView.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/26.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit


class TaskDetailInfoView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskContentTxtView: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var starOne: UIButton!
    @IBOutlet weak var starTwo: UIButton!
    @IBOutlet weak var starThree: UIButton!
    @IBOutlet weak var starFour: UIButton!
    @IBOutlet weak var starFive: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceImageView: UIImageView!
    @IBOutlet weak var distanceImageView: UIImageView!
    @IBOutlet weak var donBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var downView: UIView!
    
    var alreadyURL: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        sendButton.layer.cornerRadius = 10
        userPhoto.layer.cornerRadius = userPhoto.frame.width / 2
        donBtn.layer.cornerRadius = 10.0
        detailBtn.layer.cornerRadius = 10.0
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("TaskDetailInfoView", owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    @IBAction func request(_ sender: Any) {
        print("Send")
    }
}

extension UIView {
    func fixInView(_ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
