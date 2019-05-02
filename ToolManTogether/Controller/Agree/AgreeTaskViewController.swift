//
//  AgreeTaskViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/16.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase
import FirebaseStorage


class AgreeTaskViewController: UIViewController {
    
    @IBOutlet weak var agreeTaskTableView: UITableView!
    

    var userInfo: [RequestUserInfo]!
    var taskInfo: [UserTask]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        agreeTaskTableView.delegate = self
        agreeTaskTableView.dataSource = self
        self.title = "任務資訊"
        
        let taskAgreenib = UINib(nibName: "ProfileCell", bundle: nil)
        self.agreeTaskTableView.register(taskAgreenib, forCellReuseIdentifier: "profileTitle")
        
        let taskInfoNib = UINib(nibName: "TaskAgreeInfoCell", bundle: nil)
        self.agreeTaskTableView.register(taskInfoNib, forCellReuseIdentifier: "taskInfoCell")
        
        let goodCitizenNib = UINib(nibName: "GoodCitizenCardCell", bundle: nil)
        self.agreeTaskTableView.register(goodCitizenNib, forCellReuseIdentifier: "goodCitizen")
        
        let agreeInfoNib = UINib(nibName: "TaskDetailCell", bundle: nil)
        self.agreeTaskTableView.register(agreeInfoNib, forCellReuseIdentifier: "detailCell")
        
        let agreeDetailNib = UINib(nibName: "TaskContentCell", bundle: nil)
        self.agreeTaskTableView.register(agreeDetailNib, forCellReuseIdentifier: "contentCell")
        

    }
    
    class func profileDetailDataForTask(_ data: [RequestUserInfo], _ taskInfo: [UserTask]) -> AgreeTaskViewController {
        let storyBoard = UIStoryboard(name: "AgreeTask", bundle: nil)
        
        let viewController = storyBoard.instantiateViewController(withIdentifier: "AgreeTaskVC") as? AgreeTaskViewController
        
        if let viewController = viewController {
            viewController.userInfo = data
            viewController.taskInfo = taskInfo
        }
        return viewController!
    }
    
    func downloadUserPhoto(
        userID: String,
        finder: String,
        success: @escaping (URL) -> Void) {
        
        let storageRef = Storage.storage().reference()
        storageRef.child(finder).child(userID).downloadURL(completion: { (url, error) in
            if let error = error {
                print("User photo download Fail: \(error.localizedDescription)")
            }
            if let url = url {
                print("url \(url)")
                success(url)
            }
        })
    }
    
    func showAlert(title: String = "無法撥打電話", content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension AgreeTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileTitle", for: indexPath) as? ProfileCell {
                cell.selectionStyle = .none
                let cellData = userInfo[indexPath.row]
                cell.userName.text = cellData.fbName
                cell.userEmail.text = cellData.fbEmail
                cell.separatorView.isHidden = true
                let userID = cellData.userID
                self.downloadUserPhoto(userID: userID, finder: "UserPhoto") { (url) in
                    cell.userPhoto.sd_setImage(with: url, completed: nil)
                }
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "taskInfoCell", for: indexPath) as? TaskAgreeInfoCell {
                cell.selectionStyle = .none
                let cellData = userInfo[indexPath.row]
                cell.contentTxtView.text = cellData.aboutUser
                cell.callBtnDelegate = self
                return cell
            }
        } else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as? TaskDetailCell {
                cell.selectionStyle = .none
                let cellData = taskInfo[indexPath.row]
                cell.taskTitleLabel.text = cellData.userTaskInfo.title
                cell.taskAddress.text = cellData.userTaskInfo.address
                return cell
            }
        } else if indexPath.section == 3 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? TaskContentCell {
                cell.selectionStyle = .none

                let cellData = taskInfo[indexPath.row]
                cell.contentTxtView.text = cellData.userTaskInfo.content
                return cell
            }
        } else if indexPath.section == 4 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "goodCitizen", for: indexPath) as? GoodCitizenCardCell {
                cell.selectionStyle = .none
                cell.separatorView.isHidden = true
                let cellData = userInfo[indexPath.row]
                let userID = cellData.userID
                self.downloadUserPhoto(userID: userID, finder: "GoodCitizen") { (url) in
                    cell.imagePicker.sd_setImage(with: url, completed: nil)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension AgreeTaskViewController: CallBtnTapped {
    
    func callBtnTapped(_ send: UIButton) {
        
        if let phone = userInfo.last?.userPhone {
            
            if let url = URL(string: "tel://\(phone)") {
                UIApplication.shared.open(url)
            }else {
                showAlert(content: "無法撥打電話，請稍候再嘗試")
            }
            
        } else {
            showAlert(content: "無法撥打電話，請稍候再嘗試")
        }
    }
    
    func messageBtnTapped(_ send: UIButton) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.taskInfo = taskInfo.last
        chatLogController.userInfo = userInfo.last
        chatLogController.findRequestUserRemoteToken = userInfo.last?.userID
        self.navigationController?.show(chatLogController, sender: nil)
    }
}
