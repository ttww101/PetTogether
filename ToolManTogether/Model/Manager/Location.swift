//
//  Location.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/25.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation
import MapKit

struct UserTask {
    let taskKey: String
    let checkTask: String?
    let distance: Double?
    let userID: String?
    var userTaskInfo: UserTaskInfo
}

struct UserTaskInfo: Codable {
    let userID: String
    let userName: String
    let title: String
    let content: String
    let type: String
    let price: String
    let taskLat: Double?
    let taskLon: Double?
    let checkTask: String?
    let distance: Double?
    let time: Int?
    let ownerID: String?
    let ownAgree: String?
//    let taskKey: String?
    let agree: Bool?
    let requestKey: String?
    let requestTaskKey: String?
    let address: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case userName = "UserName"
        case title = "Title"
        case content = "Content"
        case type = "Type"
        case price = "Price"
        case taskLat = "Lat"
        case taskLon = "Lon"
        case checkTask
        case distance = "distance"
        case time = "Time"
        case ownerID = "ownerID"
        case ownAgree = "OwnerAgree"
        case agree
        case requestKey = "requestUserKey"
        case requestTaskKey = "taskKey"
        case address = "address"
    }
}

class TaskPin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
