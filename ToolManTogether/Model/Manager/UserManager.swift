//
//  UserManager.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/20.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation
import KeychainSwift

class UserManager {
    
    static let fbUser = UserManager()
    
    let fbUserDefault: UserDefaults = UserDefaults.standard
    let keychain = KeychainSwift()
    
    func getUserToken() -> String? {
        
        guard let userToken = keychain.get("token") else {
            return nil
        }
        return userToken
    }
    
    func getUserPhotoUrl() -> URL? {
        
        guard let photoURL = fbUserDefault.object(forKey: "photoURL") as? URL else {
            return nil
        }
        return photoURL
    }
    
}
