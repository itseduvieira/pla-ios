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
    private static let url = "http://api.plandoc.com.br/v1"
    
    static func getData() {
        getPreferences()
        getCompanies()
    }
    
    private static func createRequest(_ path: String, method: HTTPMethod, parameters: Parameters, _ completion: @escaping (Dictionary<String,Any>?) -> Void) {
        let headers = [
            "Authorization": "Bearer \(Auth.auth().currentUser!.uid)"
        ]
        
        let fullUrl = "\(url)/\(path)"
        
        print("\(String(method.rawValue)) \(fullUrl)")
        
        Alamofire.request(fullUrl, method: method, parameters: parameters, headers: headers).responseJSON { response in
            print(response)
            
            let json = response.result.value as? Dictionary<String,Any>
            
            completion(json)
        }
    }
    
    private static func createRequest(_ path: String, method: HTTPMethod, _ completion: @escaping (Dictionary<String,Any>?) -> Void) {
        let parameters: Parameters = [:]
        
        createRequest(path, method: method, parameters: parameters, completion)
    }
    
    static func createPreferences() {
        let parameters: Parameters = [
            "userId": Auth.auth().currentUser!.uid
        ]
        
        createRequest("preferences", method: .post, parameters: parameters, { response in
            if let json = response {
                print(json)
            }
        })
    }
    
    static func getPreferences() {
        createRequest("preferences", method: .get, { response in
            if let json = response {
                print(json)
                
                UserDefaults.standard.set(json["goalActive"] as! Bool, forKey: "goalActive")
                if let goalValue = json["goalValue"] as? Double {
                    UserDefaults.standard.set(goalValue, forKey: "goalValue")
                }
                UserDefaults.standard.set(json["notificationIncome"] as! Bool, forKey: "notificationIncome")
                UserDefaults.standard.set(json["notificationShifts"] as! Bool, forKey: "notificationShifts")
            }
        })
    }
    
    static func setPreference(_ key: String, _ value: Any) {
        let parameters: Parameters = [
            key: value
        ]
        
        createRequest("preferences", method: .put, parameters: parameters, { response in
            if let json = response {
                print(json)
            }
        })
    }
    
    static func createCompany(_ company: Company) {
        let parameters: Parameters = [
            "userId": Auth.auth().currentUser!.uid,
            "id": company.id!,
            "type": company.type!,
            "name": company.name!,
            "place": company.address!,
            "admin": company.admin!,
            "adminPhone": company.phone!,
            "color": company.color!
        ]
        
        createRequest("companies", method: .post, parameters: parameters, { response in
            if let json = response {
                print(json)
            }
        })
    }
    
    static func updateCompany(_ company: Company) {
        let parameters: Parameters = [
            "type": company.type!,
            "name": company.name!,
            "place": company.address!,
            "admin": company.admin!,
            "adminPhone": company.phone!,
            "color": company.color!
        ]
        
        createRequest("companies/\(company.id!)", method: .put, parameters: parameters, { response in
            if let json = response {
                print(json)
            }
        })
    }
    
    static func getCompanies() {
        createRequest("companies", method: .get, { response in
            if let json = response {
                print(json)
                
                /*UserDefaults.standard.set(json["goalActive"] as! Bool, forKey: "goalActive")
                if let goalValue = json["goalValue"] as? Double {
                    UserDefaults.standard.set(goalValue, forKey: "goalValue")
                }
                UserDefaults.standard.set(json["notificationIncome"] as! Bool, forKey: "notificationIncome")
                UserDefaults.standard.set(json["notificationShifts"] as! Bool, forKey: "notificationShifts")*/
            }
        })
    }
    
    static func deleteCompany(_ id: String) {
        createRequest("companies/\(id)", method: .delete, { response in
            if let json = response {
                print(json)
            }
        })
    }
    
    static func getProfile() -> Profile {
        let profile = Profile()
        
        return profile
    }
}
