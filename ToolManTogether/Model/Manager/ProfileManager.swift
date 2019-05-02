//
//  ProfileManager.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/4.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation

struct ProfileManager: Codable {
    
    let fbEmail: String?
    let fbID: String?
    let fbName: String?
    let aboutUser: String?
    let userPhone: String?
    
    enum CodingKeys: String, CodingKey {
        case fbEmail = "FBEmail"
        case fbID = "FBID"
        case fbName = "FBName"
        case aboutUser = "Aboutuser"
        case userPhone = "UserPhone"
    }
}

struct RequestUser: Codable {

    let agree: Bool
    let distance: Double
    let userID: String
    let requestTaskID: String
    let taskOwnerID: String
    let requestKey: String

    enum CodingKeys: String, CodingKey {
        case agree
        case distance
        case userID
        case requestTaskID = "RequestTaskID"
        case taskOwnerID = "UserPhone"
        case requestKey = "UserID"
    }
}

struct RequestUserInfo: Codable {
    let aboutUser: String?
    let fbEmail: String?
    let fbID: String?
    let fbName: String?
    let userPhone: String?
    let userID: String
    let remoteToken: String?
    
    enum CodingKeys: String, CodingKey {
        case aboutUser = "About"
        case fbEmail = "FBEmail"
        case fbID = "FBID"
        case fbName = "FBName"
        case userPhone = "UserPhone"
        case userID = "UserID"
        case remoteToken = "RemoteToken"
    }
}
