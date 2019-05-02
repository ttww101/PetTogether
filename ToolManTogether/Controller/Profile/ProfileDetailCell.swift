//
//  ProfileDetailCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

protocol ButtonDelegate: AnyObject {
    func doneBtnPressed(_ btnSend: UIButton,
                        _ phone: UITextField,
                        _ profileInfo: UITextView)
    
    func cancelBtnpressed(_ send: UIButton)
    func editBtnPressed(_ send: UIButton)
}

class ProfileDetailCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var profileTxtView: UITextView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var doneBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var phone: String!
    var profile: String!
    weak var btnDelegage: ButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        profileTxtView.isEditable = false
        phoneTxtField.isEnabled = false
        doneBtn.titleLabel?.isHidden = true
        cancelBtn.titleLabel?.isHidden = true
        editBtn.layer.borderWidth = 1
        editBtn.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        doneBtn.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        doneBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        cancelBtn.layer.borderWidth = 1
        profileTxtView.delegate = self
        phoneTxtField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        phone = textField.text
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        profile = textView.text
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        self.doneBtn.isHidden = true
        self.cancelBtn.isHidden = true
        profileTxtView.isEditable = false
        phoneTxtField.isEnabled = false
        editBtn.isHidden = false
        doneBtn.titleLabel?.isHidden = true
        cancelBtn.titleLabel?.isHidden = true
        doneBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
        dismissBorder()
        self.profileTxtView.backgroundColor = .white
        self.phoneTxtField.backgroundColor = .white

        btnDelegage?.doneBtnPressed(self.doneBtn,
                                    self.phoneTxtField,
                                    self.profileTxtView)
        if phone != nil {
            self.phoneTxtField.text = phone
        }
        self.profileTxtView.text = profile
        UIView.animate(withDuration: 0.1) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.profileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.doneBtn.isHidden = true
        self.cancelBtn.isHidden = true
        profileTxtView.isEditable = false
        phoneTxtField.isEnabled = false
        editBtn.isHidden = false
        doneBtn.titleLabel?.isHidden = true
        cancelBtn.titleLabel?.isHidden = true
        doneBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
        dismissBorder()
        btnDelegage?.cancelBtnpressed(self.cancelBtn)
        self.profileTxtView.backgroundColor = .white
        self.phoneTxtField.backgroundColor = .white
        
        UIView.animate(withDuration: 0.1) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.profileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
            
        }
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        self.doneBtn.isHidden = false
        self.cancelBtn.isHidden = false
        profileTxtView.isEditable = true
        phoneTxtField.isEnabled = true
        self.profileTxtView.backgroundColor = #colorLiteral(red: 0.952378909, green: 0.952378909, blue: 0.952378909, alpha: 1)
        self.phoneTxtField.backgroundColor = #colorLiteral(red: 0.952378909, green: 0.952378909, blue: 0.952378909, alpha: 1)
        editBtn.isHidden = true
        doneBtn.setTitle("確定", for: .normal)
        cancelBtn.setTitle("取消", for: .normal)
        btnDelegage?.editBtnPressed(self.cancelBtn)
        
        UIView.animate(withDuration: 0.1) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.profileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    func setBorder() {
        profileTxtView.layer.borderWidth = 1
        profileTxtView.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
        phoneTxtField.layer.borderWidth = 1
        phoneTxtField.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
    }
    
    func dismissBorder() {
        profileTxtView.layer.borderWidth = 0
        phoneTxtField.layer.borderWidth = 0
    }
}
