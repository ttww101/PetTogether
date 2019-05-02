//
//  ServcedListViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class ServcedListViewController: UIViewController {
    
    @IBOutlet weak var servcedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "任務評分紀錄"
        servcedTableView.dataSource = self
        servcedTableView.delegate = self
        let servcedListNib = UINib(nibName: "ServcedListCell", bundle: nil)
        self.servcedTableView.register(servcedListNib, forCellReuseIdentifier: "servcedListCell")
    }
}

extension ServcedListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "servcedListCell", for: indexPath) as? ServcedListCell {
            return cell
        }
        return UITableViewCell()
    }
}
