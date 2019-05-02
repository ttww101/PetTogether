//
//  Date.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/4.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation

extension Date {
    
    var millisecondsSince1970: Int {
        
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
}
