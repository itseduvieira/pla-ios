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
import PromiseKit

class DataAccess {
    private static let url = "http://api.plandoc.com.br/v1"
    
    static func getData() {
        getPreferences()
        getCompanies()
        getProfile()
        getExpenses()
        getShifts()
    }
    
    private static func createRequest(_ path: String, method: HTTPMethod, parameters: Parameters, _ completion: @escaping (Any?) -> Void) {
        let headers = [
            "Authorization": "Bearer \(Auth.auth().currentUser!.uid)"
        ]
        
        let fullUrl = "\(url)/\(path)"
        
        print("\(String(method.rawValue)) \(fullUrl)")
        
        Alamofire.request(fullUrl, method: method, parameters: parameters, headers: headers).responseJSON { response in
            completion(response.result.value)
        }
    }
    
    private static func createRequest(_ path: String, method: HTTPMethod, _ completion: @escaping (Any) -> Void) {
        let parameters: Parameters = [:]
        
        createRequest(path, method: method, parameters: parameters, completion)
    }
    
    // Preferences
    
    static func createPreferences() {
        let parameters: Parameters = [
            "userId": Auth.auth().currentUser!.uid
        ]
        
        createRequest("preferences", method: .post, parameters: parameters, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func getPreferences() {
        createRequest("preferences", method: .get, { response in
            if let json = response as? Dictionary<String,Any> {
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
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    // Company
    
    static func createCompany(_ company: Company) {
        let parameters: Parameters = [
            "id": company.id!,
            "type": company.type!,
            "name": company.name!,
            "place": company.address!,
            "admin": company.admin!,
            "adminPhone": company.phone!,
            "color": company.color!
        ]
        
        createRequest("companies", method: .post, parameters: parameters, { response in
            if let json = response as? Dictionary<String,Any> {
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
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func getCompanies() {
        createRequest("companies", method: .get, { response in
            if let json = response as? Array<Dictionary<String,Any>> {
                print(json)
                
                var companies: Dictionary<String, Data> = [:]
                
                for jsonCompany in json {
                    let pdcCompany = Company()
                    pdcCompany.id = jsonCompany["id"] as! String
                    pdcCompany.name = jsonCompany["name"] as! String
                    pdcCompany.color = jsonCompany["color"] as! String
                    pdcCompany.type = jsonCompany["type"] as! String
                    pdcCompany.phone = jsonCompany["adminPhone"] as! String
                    pdcCompany.address = jsonCompany["place"] as! String
                    pdcCompany.admin = jsonCompany["admin"] as! String
                    companies[pdcCompany.id] = NSKeyedArchiver.archivedData(withRootObject: pdcCompany)
                }
                
                UserDefaults.standard.set(companies, forKey: "companies")
            }
        })
    }
    
    static func deleteCompany(_ id: String) {
        createRequest("companies/\(id)", method: .delete, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    // Profile
    
    static func createProfile(_ profile: Profile) {
        let parameters: Parameters = [
            "crm": profile.crm!,
            "uf": profile.uf!,
            "graduationDate": profile.graduationDate!,
            "institution": profile.institution!,
            "field": profile.field!
        ]
        
        createRequest("profile", method: .post, parameters: parameters, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func updateProfile(_ profile: Profile) {
        let parameters: Parameters = [
            "crm": profile.crm!,
            "uf": profile.uf!,
            "graduationDate": profile.graduationDate!,
            "institution": profile.institution!,
            "field": profile.field!
        ]
        
        createRequest("profile", method: .put, parameters: parameters, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func getProfile() {
        createRequest("profile", method: .get, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
                
                if json.count > 0 {
                    let profile = Profile()
                    profile.crm = json["crm"] as! String
                    profile.uf = json["uf"] as! String
                    profile.graduationDate = json["graduationDate"] as! String
                    profile.institution = json["institution"] as! String
                    profile.field = json["field"] as! String
                    
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: profile), forKey: "profile")
                }
            }
        })
    }
    
    // Expenses
    
    static func createExpense(_ expense: Expense) {
        var parameters: Parameters = [
            "id": expense.id!,
            "title": expense.title!,
            "value": expense.value!,
            "date": expense.date!
        ]
        
        if expense.groupId != nil {
            parameters["groupId"] = expense.groupId
        }
        
        createRequest("expenses", method: .post, parameters: parameters, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func updateExpense(_ expense: Expense) {
        let parameters: Parameters = [
            "id": expense.id!,
            "title": expense.title!,
            "value": expense.value!,
            "date": expense.date!
        ]
        
        createRequest("expenses/\(expense.id!)", method: .put, parameters: parameters, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func getExpenses() {
        createRequest("expenses", method: .get, { response in
            if let json = response as? Array<Dictionary<String,Any>> {
                print(json)
                
                var expenses: Dictionary<String, Data> = [:]
                
                for jsonExpense in json {
                    let pdcExpense = Expense()
                    pdcExpense.id = jsonExpense["id"] as! String
                    pdcExpense.title = jsonExpense["title"] as! String
                    pdcExpense.value = jsonExpense["value"] as! Double
                    
                    let formatter = DateFormatter()
                    formatter.calendar = Calendar(identifier: .iso8601)
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                    
                    if let groupId = jsonExpense["groupId"] as? String {
                        pdcExpense.groupId = groupId
                    }
                    
                    pdcExpense.date = formatter.date(from: jsonExpense["date"] as! String)
                    expenses[pdcExpense.id] = NSKeyedArchiver.archivedData(withRootObject: pdcExpense)
                }
                
                UserDefaults.standard.set(expenses, forKey: "expenses")
            }
        })
    }
    
    static func deleteExpense(_ id: String) {
        createRequest("expenses/\(id)", method: .delete, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func deleteExpenseGroup(_ groupId: String) {
        createRequest("expenses/group/\(groupId)", method: .delete, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    // Shift
    
    static func createShift(_ shift: Shift) {
        var parameters: Parameters = [
            "id": shift.id!,
            "companyId": shift.companyId!,
            "date": shift.date!,
            "paymentDueDate": shift.paymentDueDate!,
            "paymentType": shift.paymentType!,
            "salary": shift.salary!,
            "shiftTime": shift.shiftTime!
        ]
        
        if shift.groupId != nil {
            parameters["groupId"] = shift.groupId
        }
        
        createRequest("shifts", method: .post, parameters: parameters, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func updateShift(_ shift: Shift) {
        let parameters: Parameters = [
            "companyId": shift.companyId!,
            "date": shift.date!,
            "paid": shift.paid!,
            "paymentDueDate": shift.paymentDueDate!,
            "paymentType": shift.paymentType!,
            "salary": shift.salary!,
            "shiftTime": shift.shiftTime!
        ]
        
        createRequest("shifts/\(shift.id!)", method: .put, parameters: parameters, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func getShifts() {
        createRequest("shifts", method: .get, { response in
            if let json = response as? Array<Dictionary<String,Any>> {
                print(json)
                
                var shifts: Dictionary<String, Data> = [:]
                
                for jsonShift in json {
                    let pdcShift = Shift()
                    pdcShift.id = jsonShift["id"] as! String
                    pdcShift.companyId = jsonShift["companyId"] as! String
                    pdcShift.paid = jsonShift["paid"] as! Bool
                    pdcShift.salary = jsonShift["salary"] as! Double
                    pdcShift.shiftTime = jsonShift["shiftTime"] as! Int
                    pdcShift.paymentType = jsonShift["paymentType"] as! String
                    
                    let formatter = DateFormatter()
                    formatter.calendar = Calendar(identifier: .iso8601)
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                    pdcShift.date = formatter.date(from: jsonShift["date"] as! String)
                    pdcShift.paymentDueDate = formatter.date(from: jsonShift["paymentDueDate"] as! String)
                    
                    if let groupId = jsonShift["groupId"] as? String {
                        pdcShift.groupId = groupId
                    }
                    
                    shifts[pdcShift.id] = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
                }
                
                UserDefaults.standard.set(shifts, forKey: "shifts")
            }
        })
    }
    
    static func deleteShift(_ id: String) {
        createRequest("shifts/\(id)", method: .delete, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
    
    static func deleteShiftGroup(_ groupId: String) {
        createRequest("shifts/group/\(groupId)", method: .delete, { response in
            if let json = response as? Dictionary<String,Any> {
                print(json)
            }
        })
    }
}
