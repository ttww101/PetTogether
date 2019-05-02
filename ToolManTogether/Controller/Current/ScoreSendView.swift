//
//  ScoreSendView.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

protocol AlertViewDelegate {
    func alertBtn(actionType: String)
}

class ScoreSendView: UIView {
    
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    var delegate: AlertViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.center = CGPoint(x: UIScreen.main.bounds.midX, y: -self.frame.size.height)
        self.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 30
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor(white: 0, alpha: 0.5).cgColor
        self.layer.opacity = 0
        self.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 4))
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
            self.layer.opacity = 1
            self.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }, completion: nil)
        
    }
    
    @IBAction func okButton(_ sender: Any) {
        delegate?.alertBtn(actionType: "confirm")
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        delegate?.alertBtn(actionType: "cancel")
    }
    
}
