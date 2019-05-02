//
//  HTTPClient.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/19.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Alamofire

enum TokenError: Error {
    case requestFailed
    case requestUnsuccessful(statusCode: Int)
    case invaliDate
    case couldNotGetStatusCode
}

class HTTPClient {
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    typealias SendNotification = (Bool?, Error?) -> Void
    typealias FbLogOutCompletionHandler = (Bool?, Error?) -> Void

    func sendNotification(fromToken: String, toToken: String,
                          title: String, content: String,
                          taskInfoKey: String?, fromUserId: String?,
                          type: String?, badge: Int,
                          completion: @escaping SendNotification) {
        
        let notificationURL: URL = URL(string: "https://fcm.googleapis.com/fcm/send")!
        
        let headers = ["Authorization":"key= AAAA9W3CEaU:APA91bFu_A4iZmJxQbOlXJ3AscE4mwA-A1MGVLKra_HbRhTHt1aVWDrCenaSII6W_NCXI88-84xsp_UZHxCxoBmTLlk-sgOGyJZ3j44-VcpTMwDYmktBMdH7eAK2dITFd3inB0HlQ_wi"]
        
        let parameters = ["to": toToken, "priority" : "high", "notification": [
           
            "body": content,
            "title": title,
            "sound": "default",
            "category": "INVITATION",
            "badge": badge],
                          "data" : ["taskInfoKey": taskInfoKey,
                                    "fromUserId": fromUserId,
                                    "type": type]] as [String : Any]
    
        Alamofire.request(notificationURL, method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers).validate().responseData { (response) in
            
                            guard response.result.isSuccess else {
                                let errorMessage = response.result.error
                                completion(nil, errorMessage)
                                return
                            }
                            
                            guard response.result.value != nil else {
                                completion(nil, TokenError.invaliDate)
                                return
                            }
                            
                           completion(true, nil)
        }
    }
    
}
