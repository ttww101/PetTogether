//
//  SearchTaskViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/27.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import FirebaseDatabase
import Lottie
import KeychainSwift

class SearchTaskViewController: UIViewController {
    
    @IBOutlet weak var searchTaskTableVIew: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var aniView: UIView!
    @IBOutlet weak var bgLabel: UILabel!
    
    var photoURL: [URL] = []
    var myRef: DatabaseReference!
    var selectTaskKey: [String] = []
    let decoder = JSONDecoder()
    var selectTask = [UserTask]()
    var reloadFromFirebase = false
    var taskOwnerInfo: [RequestUserInfo] = []
    var myActivityIndicator: UIActivityIndicatorView!
    let fullScreenSize = UIScreen.main.bounds.size
    let keychain = KeychainSwift()
    var photoUrl: [URL] = []
    var userPhoto: [String:URL] = [:]
    let animationView = LOTAnimationView(name: "servishero_loading")
    var selectTaskOwner: UserTask!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkInternet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.removeFromSuperview()
        guestMode()
        setAniView()
        searchTaskTableVIew.showsVerticalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicator()
        let searchNib = UINib(nibName: "searchTaskCell", bundle: nil)
        self.searchTaskTableVIew.register(searchNib, forCellReuseIdentifier: "searchTask")
        searchTaskTableVIew.delegate = self
        searchTaskTableVIew.dataSource = self
        myRef = Database.database().reference()
        selectTaskAdd()
        
        let notificationName = Notification.Name("sendRequest")
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectTaskAdd), name: notificationName, object: nil)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        Database.database().callbackQueue = DispatchQueue(label: "spock_queue", qos: .userInitiated, attributes: [.concurrent])

    }
    
    @IBAction func messageListTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "ControllerMessage", bundle: nil)
        if let controllerMessageVC = storyboard.instantiateViewController(withIdentifier: "controllerMessage") as? MessageController {
            self.show(controllerMessageVC, sender: nil)
        }
    }
    
    func checkInternet() {
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            
            self.showAlert(title: "網路連線有問題", content: "網路行為異常，請確認您的網路連線狀態或稍後再試。")
        }
    }
    
    func guestMode() {
        if keychain.get("token") == nil {
            changeView()
        }
    }
    
    func setAniView() {
        animationView.frame = aniView.frame
        animationView.center = aniView.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = false
        bgView.addSubview(animationView)
        animationView.play()
    }
    
    func changeView() {
        self.bgView.isHidden = false
        self.aniView.isHidden = false
        self.bgLabel.isHidden = false
        
    }
    
    func returnView() {
        self.bgView.isHidden = true
        self.aniView.isHidden = true
        self.bgLabel.isHidden = true
    }
    
    func setIndicator() {
        myActivityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        myActivityIndicator.color = UIColor.gray
        myActivityIndicator.backgroundColor = UIColor.white
        myActivityIndicator.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.5)
        self.searchTaskTableVIew.addSubview(myActivityIndicator)
    }
    
    func showAlert(title: String = "", content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func selectTaskAdd() {
        myActivityIndicator.startAnimating()
        self.selectTask.removeAll()
        self.selectTaskKey.removeAll()
        guard let userID = Auth.auth().currentUser?.uid else { return }

        myRef.child("RequestTask")
            .queryOrdered(byChild: "UserID").queryEqual(toValue: userID)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let data = snapshot.value as? NSDictionary else {
                    self.changeView()
                    return
                }
                
                self.returnView()
                
                for value in data {
                    guard let keyValue = value.key as? String else { return }
                    let dictionary = value.value
                    
                    guard let taskInfoJSONData = try? JSONSerialization.data(withJSONObject: dictionary) else {
                        return
                    }
                    
                    do {
                        let taskData = try self.decoder.decode(UserTaskInfo.self, from: taskInfoJSONData)
                        self.selectTask.append(UserTask.init(taskKey: keyValue, checkTask: nil, distance: nil, userID: nil, userTaskInfo: taskData))
                        
                    } catch {
                        print(error)
                    }
                    
                    self.selectTask.sort(by: { $0.userTaskInfo.time! > $1.userTaskInfo.time! })
                    
                    self.selectTaskChange(requestTaskKey: keyValue)

                }
                self.searchTaskTableVIew.reloadData()
                self.myActivityIndicator.stopAnimating()
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    func selectTaskChange(requestTaskKey: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

            myRef.child("RequestTask")
                .child(requestTaskKey)
                .observe(.childChanged) { (snapshot) in
                    
                    self.myRef.child("RequestTask")
                        .queryOrdered(byChild: "UserID").queryEqual(toValue: userID)
                        .observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            self.selectTask.removeAll()
                            guard let data = snapshot.value as? NSDictionary else { return }
                            for value in data {
                                guard let keyValue = value.key as? String else { return }
                                let dictionary = value.value

                                guard let taskInfoJSONData = try? JSONSerialization.data(withJSONObject: dictionary) else {
                                    return
                                }
                                
                                do {
                                    let taskData = try self.decoder.decode(UserTaskInfo.self, from: taskInfoJSONData)
                                    self.selectTask.append(UserTask.init(taskKey: keyValue, checkTask: nil, distance: nil, userID: nil, userTaskInfo: taskData))
                                    
                                } catch {
                                    print(error)
                                }

                                self.selectTask.sort(by: { $0.userTaskInfo.time! > $1.userTaskInfo.time! })
                            }
                            self.searchTaskTableVIew.reloadData()
                        }
            )}
    }
    
    func searchTaskOwnerInfo(ownerID: String, taskInfo: UserTask, button: UIButton) {
        
            myRef.child("UserData").queryOrderedByKey()
                .queryEqual(toValue: ownerID)
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    self.taskOwnerInfo.removeAll()
                    guard let data = snapshot.value as? NSDictionary else { return }
                    for value in data.allValues {
                        
                        guard let taskOwnerJSONData = try? JSONSerialization.data(withJSONObject: value) else {
                            return
                        }
                        
                        do {
                            let taskData = try self.decoder.decode( RequestUserInfo.self, from: taskOwnerJSONData)
                            self.taskOwnerInfo.append(taskData)
                            
                        } catch {
                            print(error)
                        }
                    }
                    
                    let viewController = AgreeTaskViewController.profileDetailDataForTask(self.taskOwnerInfo, [taskInfo])
                    
                    button.isEnabled = true
                    self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension SearchTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchTask", for: indexPath) as? SearchTaskCell {
            
            cell.searchTaskView.detailBtn.tag = indexPath.row
            cell.searchTaskView.reportBtn.tag = indexPath.row
            cell.searchTaskView.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            let cellData = selectTask[indexPath.row].userTaskInfo
            let distance = selectTask[indexPath.row].distance
            
            cell.selectionStyle = .none
            cell.searchTaskView.taskTitleLabel.text = cellData.title
            cell.searchTaskView.userName.text = cellData.userName
            cell.searchTaskView.taskContentTxtView.text = cellData.content
            cell.searchTaskView.distanceLabel.text = "\(cellData.distance!)km"
            cell.searchTaskView.typeLabel.text = cellData.type
            cell.searchTaskView.priceLabel.text = cellData.price
            
            // 等待
            if cellData.ownAgree == "waiting" {
                cell.searchTaskView.sendButton.setTitle("對方尚未同意", for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = .white
                cell.searchTaskView.sendButton.isEnabled = false
                cell.searchTaskView.sendButton.isHidden = false
                cell.searchTaskView.sendButton.setTitleColor(#colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1), for: .normal)
                cell.searchTaskView.detailBtn.isHidden = true

            // 對方同意
            } else if cellData.ownAgree == "agree" {
                cell.isSelected = true
                cell.isEditing = true
                cell.searchTaskView.sendButton.setTitle("對方已經同意", for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
                cell.searchTaskView.sendButton.isEnabled = false
                cell.searchTaskView.sendButton.isHidden = true
                cell.searchTaskView.detailBtn.isHidden = false
                
                if let ownerID = cellData.ownerID {
                    cell.searchTaskView.detailBtn.addTarget(self, action: #selector(detailBtnTapped(data:)), for: .touchUpInside)
                }
                
             // 對方拒絕
            } else if cellData.ownAgree == "disAgree" {
                cell.searchTaskView.sendButton.setTitle("對方已拒絕", for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = .white
                cell.searchTaskView.sendButton.isEnabled = true
                cell.searchTaskView.sendButton.isHidden = false
                cell.searchTaskView.sendButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.searchTaskView.detailBtn.isHidden = true

             // 對方刪除
            } else if cellData.ownAgree == "delete" {
                cell.searchTaskView.sendButton.setTitle("對方已刪除任務", for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = .white
                cell.searchTaskView.sendButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.searchTaskView.detailBtn.isHidden = true
                cell.searchTaskView.sendButton.isEnabled = true
                cell.searchTaskView.sendButton.isHidden = false
            }
            
            cell.searchTaskView.userPhoto.image = UIImage(named: "profile_sticker_placeholder02")

            if let ownerID = cellData.ownerID {
                
                if let userURL =  self.userPhoto[String(ownerID)] {
                    
                cell.searchTaskView.userPhoto.sd_setImage(with: userURL, completed: nil)
                    
                } else {
                    updataTaskUserPhoto(userID: ownerID) { (url) in
                        if url == url {
                            self.userPhoto["\(ownerID)"] = url
                            cell.searchTaskView.userPhoto.sd_setImage(with: url, completed: nil)
                        } else {
                            cell.searchTaskView.userPhoto.image = UIImage(named: "profile_sticker_placeholder02")
                        }
                    }
                }
            }
            
            cell.searchTaskView.reportBtn.addTarget(self, action: #selector(showAlert(send:)), for: .touchUpInside)
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    @objc func detailBtnTapped(data: UIButton) {
        print("detail")
        selectTaskOwner = selectTask[data.tag]
        if let taskOwnerID = selectTaskOwner.userTaskInfo.ownerID {
            
            self.searchTaskOwnerInfo(ownerID: taskOwnerID, taskInfo: selectTaskOwner, button: data)
        }
        
        data.isEnabled = false
    }
    
    @objc func showAlert(send: UIButton) {
        
        let requestTask = selectTask[send.tag].userTaskInfo.checkTask
        let taskKey = selectTask[send.tag].userTaskInfo.requestTaskKey
        let userKey = selectTask[send.tag].userTaskInfo.requestKey

        let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "檢舉", style: .destructive) { (void) in
            
            let reportController = UIAlertController(title: "確定檢舉？", message: "我們會儘快處理", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .destructive, handler: nil)
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            reportController.addAction(cancelAction)
            reportController.addAction(okAction)
            self.present(reportController, animated: true, completion: nil)
        }
        
        let deltetAction = UIAlertAction(title: "從列表中刪除", style: .default) { (void) in
            let reportController = UIAlertController(title: "確定刪除？", message: "刪除後將無法再看到該任務", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .destructive, handler: { (void) in
                
                if let requestTaskKey = requestTask {
                    self.myRef.child("RequestTask").queryOrdered(byChild: "checkTask").queryEqual(toValue: requestTaskKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let data = snapshot.value as? NSDictionary else { return }
                        
                        for value in data {
                            guard let keyValue = value.key as? String else { return }
                            
                            self.myRef.child("RequestTask").child(keyValue).removeValue()
                            let index = IndexPath(row: send.tag, section: 0)
                            
                            if let userKey = userKey, let taskKey = taskKey {
                                
                                let userId = Auth.auth().currentUser?.uid
                            self.myRef.child("Task").child(taskKey).child("RequestUser").child(userKey).removeValue()
                                
                                self.myRef.child("userAllTask").child(userId!).child(taskKey).removeValue()
                                
                                self.delectMessageData(taskKey: taskKey, taskInfo:                  self.selectTask[send.tag].userTaskInfo)
                                self.selectTask.remove(at: send.tag)

                            }
                            
                            self.searchTaskTableVIew.performBatchUpdates({
                                self.searchTaskTableVIew.deleteRows(at: [index], with: .left)
                                
                            }, completion: {
                                (finished: Bool) in
                                self.searchTaskTableVIew.reloadData()
                                if self.selectTask.count == 0 {
                                    self.changeView()
                                }
                                print("刪除完成")
                            })
                        }
                    })
                }
            })
            
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            reportController.addAction(cancelAction)
            reportController.addAction(okAction)
            self.present(reportController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        personAlertController.addAction(reportAction)
        personAlertController.addAction(deltetAction)
        personAlertController.addAction(cancelAction)
        self.present(personAlertController, animated: true, completion: nil)
    }
    
    func delectMessageData(taskKey: String, taskInfo: UserTaskInfo) {
        
        let autoID = myRef.childByAutoId().key
        let timestamp = Double(Date().millisecondsSince1970)
        
        myRef.child("Message").child(taskKey).child(autoID!).updateChildValues([
            "message": "對方已離開任務聊天室",
            "fromId": autoID!,
            "timestamp": timestamp,
            "taskTitle": taskInfo.title,
            "taskOwnerId": taskInfo.ownerID,
            "taskKey": taskKey,
            "taskType": taskInfo.type])
    }
    
    func updataTaskUserPhoto(
        
        userID: String,
        success: @escaping (URL) -> Void) {
        
        myActivityIndicator.startAnimating()
        let storageRef = Storage.storage().reference()
        
        storageRef.child("UserPhoto").child(userID).downloadURL(completion: { (url, error) in
            
            if let error = error {
                print("User photo download Fail: \(error.localizedDescription)")
            }
            
            if let url = url {
                print("url \(url)")
                self.photoUrl.append(url)
                success(url)
                self.myActivityIndicator.stopAnimating()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
