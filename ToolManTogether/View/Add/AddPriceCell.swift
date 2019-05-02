//
//  AddPriceCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/17.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class AddPriceCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var priceTxtfield: UITextField!
    
    var titleCompletion: ((_ data: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        priceTxtfield.delegate = self
        
        let claneDataNotification = Notification.Name("addTask")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.cleanData), name: claneDataNotification, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let titleTxt = textField.text {
            titleCompletion?(titleTxt)
        }
    }
    
    @objc func cleanData() {
        priceTxtfield.text = ""
    }
    
}
