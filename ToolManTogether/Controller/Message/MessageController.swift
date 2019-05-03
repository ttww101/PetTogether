//
//  MessageController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/24.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase
import FirebaseStorage
import FirebaseMessaging


class MessageController: UIViewController {
    
    @IBOutlet weak var messageListTableView: UITableView!
    var myRef: DatabaseReference!
    var userAllTaskKey: [MessageTaskKey] = []
    var userAllMessage: [Message] = []
    var messagesDictionary = [String: Message]()
    var taskInfo: [UserTask] = []
    var taskOwnerInfo: [RequestUserInfo] = []
    var requestUserInfo: [RequestUser] = []
    var toUserId: String!
    let decoder = JSONDecoder()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageListTableView.allowsSelection = true
        getUserAkkTaskKey()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageListTableView.delegate = self
        messageListTableView.dataSource = self
        myRef = Database.database().reference()
        
        let messageListNib = UINib(nibName: "controllerMessage", bundle: nil)
        self.messageListTableView.register(messageListNib, forCellReuseIdentifier: "controllerMessage")
        
        getUserAkkTaskKey()
        
        self.title = "任務聊天室"
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        resetBadgeCount()
        
    }

    func resetBadgeCount() {
        
        guard let myId = Auth.auth().currentUser?.uid else {
            /// FIXME: 新增 alert view
            return
        }
        
        myRef.child("Badge").child(myId).updateChildValues([
            "messageBadge": 1
            ])
    }
    
    func getUserAkkTaskKey() {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            /// FIXME: 新增 alert view
            return
        }
        
        myRef.child("userAllTask").queryOrderedByKey()
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { [weak self] (snapshot) in
                
                guard let data = snapshot.value as? NSDictionary else { return }
                
                for value in data.allValues {
                    guard let dictionary = value as? [String: Any] else { return }
                    guard let `self` = self else { return }
                    for taskValue in dictionary.values {
                        guard let dictionaryValue = taskValue as? [String: String] else { return }
                        guard let taskKey = dictionaryValue["taskKey"] else { return }
                        guard let taskTitle = dictionaryValue["taskTitle"] else { return }
                        guard let taskOwnerName = dictionaryValue["taskOwnerName"] else { return }
                        let data = MessageTaskKey(taskKey: taskKey, taskTitle: taskTitle, taskOwnerName: taskOwnerName)
                        self.userAllTaskKey.append(data)
                    }
                }
                self?.messageListTableView.reloadData()
                self?.getMessageListByKey()
        }
    }
    
    func getMessageListByKey() {
        
        let userId = Auth.auth().currentUser?.uid
        
        for data in userAllTaskKey {
            myRef.child("Message")
                .child(data.taskKey)
                .observe(.childAdded) { [weak self] (snapshot) in
                    if let dictionary = snapshot.value as? [String: Any] {
                        //                        let taskKey = snapshot.key as? String
                        print(dictionary)
                        
                        let fromId = dictionary["fromId"] as? String
                        let text = dictionary["message"] as? String
                        let timestamp = dictionary["timestamp"] as? Double
                        let imageUrl = dictionary["imageUrl"] as? String
                        let taskTitle = dictionary["taskTitle"] as? String
                        let taskOwnerName = dictionary["taskOwnerName"] as? String
                        let taskOwnerId = dictionary["taskOwnerId"] as? String
                        let taskKey = dictionary["taskKey"] as? String
                        let taskType = dictionary["taskType"] as? String
                        let seen = dictionary["\(userId!)_see"] as? String
                        
                        let message = Message(fromId: fromId, text: text,
                                              timestamp: timestamp, taskTitle: taskTitle,
                                              taskOwnerName: taskOwnerName,
                                              taskOwnerId: taskOwnerId, taskKey: taskKey,
                                              taskType: taskType, seen: seen,
                                              imageUrl: imageUrl,imageHeight: nil,
                                              imageWidth: nil)
                        
                        guard let stroungSelf = self else { return }
                        
                        stroungSelf.messagesDictionary[data.taskKey] = message
                        
                        stroungSelf.userAllMessage = Array(stroungSelf.messagesDictionary.values)
                        
                        self?.userAllMessage.sort(by: { (message1, message2) -> Bool in
                            return Int(message1.timestamp!) > Int(message2.timestamp!)
                        })
                        
                        stroungSelf.messageListTableView.reloadData()
                    }
            }
        }
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
}

extension MessageController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAllMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "controllerMessage", for: indexPath) as? ControllerMessageCell {
            
            cell.selectionStyle = .none

            let cellData = userAllMessage[indexPath.row]
            let userId = Auth.auth().currentUser?.uid
            
            if cellData.seen == nil {
                cell.messageLabel.font = UIFont(name: "PingFangTC-Semibold", size: 15)
                cell.taskNameLabel.font = UIFont(name: "PingFangTC-Semibold", size: 18)
                cell.dateLabel.font = UIFont(name: "PingFangTC-Semibold", size: 14)
                cell.messageLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell.dateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

            } else {
                cell.messageLabel.font = UIFont(name: "PingFangTC-Regular", size: 15)
                cell.taskNameLabel.font = UIFont(name: "PingFangTC-Regular", size: 18)
                cell.dateLabel.font = UIFont(name: "PingFangTC-Regular", size: 14)
                cell.messageLabel.textColor = UIColor.darkGray
                cell.dateLabel.textColor = UIColor.darkGray
            }
            
            cell.taskNameLabel.text = cellData.taskTitle
            cell.taskType.text = cellData.taskType

            if cellData.text == nil && cellData.imageUrl != nil {
                cell.messageLabel.text = "收到圖片"
            } else {
                cell.messageLabel.text = cellData.text
            }
            
            if let seconds = cellData.timestamp {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "hh:mm a"
                cell.dateLabel.text = dateFormater.string(from: timestampDate)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellData = userAllMessage[indexPath.row]
        
        let allow = checkUserLeave(allData: userAllMessage, cellData: cellData)
        
        tableView.cellForRow(at: indexPath)!.isSelected = allow

    }
    
    func checkUserLeave(allData: [Message], cellData: Message) -> Bool {
        
        if cellData.text == "對方已關閉任務聊天室" || cellData.text == "對方已離開任務聊天室" || cellData.text == "已封鎖任務聊天室" {
                return false
            } else {
                getUserTaskInfo(cellData: cellData)
                return true
            }
        return false
    }

    func getUserTaskInfo(cellData: Message) {
        
        let myId = Auth.auth().currentUser?.uid
        
        myRef.child("Task").queryOrderedByKey().queryEqual(toValue: cellData.taskKey!).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let data = snapshot.value as? NSDictionary else {
                return
            }
            
            for value in data {
                
                guard let keyValue = value.key as? String else { return }
                guard let requestDictionary = value.value as? [String: Any] else { return }
                guard let requestUser = requestDictionary["RequestUser"] as? NSDictionary else { return }
                let dictionary = value.value

                for requestUserData in requestUser {
                    
                    guard let keyValue = requestUserData.key as? String else { return }
                    print(requestUserData.value)
                    
                    let requestDictionary = requestUserData.value
                    
                    guard let taskInfoJSONData = try? JSONSerialization.data(withJSONObject: requestDictionary) else {
                        return
                    }
                    
                    do {
                        let requestUserData = try self.decoder.decode(RequestUser.self, from: taskInfoJSONData)
                        if requestUserData.agree == true {
                            self.requestUserInfo.append(requestUserData)
                        }
                    } catch {
                        print(error)
                    }
                }
                
                guard let taskInfoJSONData = try? JSONSerialization.data(withJSONObject: dictionary) else {
                    return
                }
                
                do {
                    let taskData = try self.decoder.decode(UserTaskInfo.self, from: taskInfoJSONData)
                    self.taskInfo.append(UserTask.init(taskKey: keyValue, checkTask: nil, distance: nil, userID: nil, userTaskInfo: taskData))
                } catch {
                    print(error)
                }
            }
        }
        
        myRef.child("UserData").queryOrderedByKey()
            .queryEqual(toValue: cellData.taskOwnerId!)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let data = snapshot.value as? NSDictionary else { return }
                for value in data.allValues {
                    
                    guard let dictionary = value as? [String: Any] else { return }
                    print(dictionary)
                    let aboutUser = dictionary["AboutUser"] as? String
                    let fbEmail = dictionary["FBEmail"] as? String
                    let fbID = dictionary["FBID"] as? String
                    let fbName = dictionary["FBName"] as? String
                    let userPhone = dictionary["UserPhone"] as? String
                    guard let userID = dictionary["UserID"] as? String else { return }
                    let remoteToken = dictionary["RemoteToken"] as? String
                    
                    let extractedExpr = RequestUserInfo(aboutUser: aboutUser,
                                                        fbEmail: fbEmail,
                                                        fbID: fbID,
                                                        fbName: fbName,
                                                        userPhone: userPhone, userID: userID,
                                                        remoteToken: remoteToken)
                    self.taskOwnerInfo.append(extractedExpr)
                }
                
                let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
                chatLogController.taskInfo = self.taskInfo.last
                chatLogController.userInfo = self.taskOwnerInfo.last
                
                if self.requestUserInfo.last?.userID != myId! {
                    chatLogController.findRequestUserRemoteToken = self.requestUserInfo.last?.userID
                } else {
                    chatLogController.findRequestUserRemoteToken = self.taskInfo.last?.userID
                }
                
                chatLogController.fromTaskOwner = true
                self.navigationController?.show(chatLogController, sender: nil)
        }
    }
}
