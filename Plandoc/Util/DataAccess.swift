//
//  DataAccess.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 02/05/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import Foundation
import Alamofire
import FirebaseAuth

class DataAccess {
    static func createPreferences() {
        let parameters: Parameters = [
            "userId": Auth.auth().currentUser!.uid
        ]
        
        Alamofire.request("http://api.plandoc.com.br/v1/preferences", method: .post, parameters: parameters).responseJSON { response in
            if let json = response.result.value as? Dictionary<String,Any> {
                print(json)
            }
        }
    }
    
    static func getPreferences() {
        Alamofire.request("http://api.plandoc.com.br/v1/preferences/\(Auth.auth().currentUser!.uid)").responseJSON { response in
            if let json = response.result.value as? Dictionary<String,Any> {
                print(json)
                
                UserDefaults.standard.set(json["goalActive"] as! Bool, forKey: "goalActive")
                if let goalValue = json["goalValue"] as? Double {
                    UserDefaults.standard.set(goalValue, forKey: "goalValue")
                }
                UserDefaults.standard.set(json["notificationIncome"] as! Bool, forKey: "notificationIncome")
                UserDefaults.standard.set(json["notificationShifts"] as! Bool, forKey: "notificationShifts")
            }
        }
    }
    
    static func setPreference(_ key: String, _ value: Any) {
        let parameters: Parameters = [
            key: value
        ]
        
        Alamofire.request("http://api.plandoc.com.br/v1/preferences/\(Auth.auth().currentUser!.uid)", method: .put, parameters: parameters).responseJSON { response in
            if let json = response.result.value as? Dictionary<String,Any> {
                print(json)
            }
        }
    }
    
    static func getProfile() -> Profile {
        let profile = Profile()
        
        return profile
    }
}
