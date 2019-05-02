//
//  NotificationAgreeViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/16.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class NotificationAgreeViewController: UIViewController {
    
    @IBOutlet weak var notificationAgreeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationAgreeTableView.delegate = self
        notificationAgreeTableView.dataSource = self
    }
    
    class func profileDetailDataForTask(_ data: String) -> NotificationAgreeViewController {
        let storyBoard = UIStoryboard(name: "NotificationAgree", bundle: nil)
        
        let viewController = storyBoard.instantiateViewController(withIdentifier: "NotificationAgree") as? NotificationAgreeViewController
        
        return viewController!
    }
}

extension NotificationAgreeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
