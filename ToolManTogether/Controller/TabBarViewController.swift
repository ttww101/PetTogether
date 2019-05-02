//
//  TabBarViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/20.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

private enum Tab {
    case home
    case addTask
    case searchTask
    case historyTask
    case profile
    
    func controller() -> UIViewController {
      
        switch self {
        case .home:
            return UIStoryboard.homeStoryboard().instantiateInitialViewController()!
            
        case .addTask:
            return UIStoryboard.addStoryboard().instantiateInitialViewController()!
            
        case .searchTask:
            return UIStoryboard.searchTask().instantiateInitialViewController()!
            
        case .historyTask:
            return UIStoryboard.historyTask().instantiateInitialViewController()!
            
        case .profile:
            return UIStoryboard.profile().instantiateInitialViewController()!
        }
    }
    
    func image() -> UIImage {
        switch self {
        case.home: return #imageLiteral(resourceName: "tab_main_normal")
        case .addTask: return #imageLiteral(resourceName: "tabbar-3")
        case .searchTask: return #imageLiteral(resourceName: "tabbar-2")
        case .historyTask: return #imageLiteral(resourceName: "tabbar-4")
        case .profile: return #imageLiteral(resourceName: "tabbar-6")
        }
    }
    
    func title() -> String {
        switch self {
        case.home: return "搜尋"
        case .addTask: return "新增"
        case .searchTask: return "已接任務"
        case .historyTask: return "目前配對"
        case .profile: return "個人"
        }
    }
}

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setTab()
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
    }
    
    private func setTab() {
        tabBar.tintColor = #colorLiteral(red: 0.9568627451, green: 0.7215686275, blue: 0, alpha: 1)
        tabBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        var controllers: [UIViewController] = []
        let tabs: [Tab] = [.home, .searchTask, .addTask, .historyTask, .profile]
        for myTab in tabs {
            let controller = myTab.controller()
            let item = UITabBarItem(title: myTab.title(), image: myTab.image(), selectedImage: nil)
            controller.tabBarItem = item
            controllers.append(controller)
        }
        setViewControllers(controllers, animated: true)
    }
}
