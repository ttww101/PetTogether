//
//  Message.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation

struct Message {
    var fromId: String?
    var text: String?
    var timestamp: Double?
    var taskTitle: String?
    var taskOwnerName: String?
    var taskOwnerId: String?
    var taskKey: String?
    var taskType: String?
    var seen: String?

    var imageUrl: String?
    var imageHeight: Double?
    var imageWidth: Double?
}

struct MessageTaskKey {
    var taskKey: String
    var taskTitle: String
    var taskOwnerName: String
}
