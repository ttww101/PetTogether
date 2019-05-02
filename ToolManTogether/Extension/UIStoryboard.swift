//
//  UIStoryboard.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/19.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func loginStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }
    
    static func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static func homeStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "home", bundle: nil)
    }
    
    static func addStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "addTask", bundle: nil)
    }
    
    static func searchTask() -> UIStoryboard {
        return UIStoryboard(name: "searchTask", bundle: nil)
    }
    
    static func historyTask() -> UIStoryboard {
        return UIStoryboard(name: "historyTask", bundle: nil)
    }
    
    static func profile() -> UIStoryboard {
    return UIStoryboard(name: "profile", bundle: nil)
    }
    
}
