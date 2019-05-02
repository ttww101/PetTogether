//
//  NotificationViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/12.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func didReceive(_ notification: UNNotification) {
         self.titleLabel?.text = notification.request.content.title
         self.bodyLabel?.text = notification.request.content.body
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void)
    {
        if response.actionIdentifier == "accept"
        {
            print("Accept - from Extension")
            DispatchQueue.main.async {
                completion(.dismissAndForwardAction)
            }
        }
        else
        {
            DispatchQueue.main.async {
                completion(.dismiss)
            }
        }
    }



}
