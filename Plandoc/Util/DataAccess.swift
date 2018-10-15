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
    private let url = "http://api.plandoc.com.br/v1"
    
    var sessionManager: SessionManager!
    
    static let instance = DataAccess()
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 8
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        sessionManager.retrier = PdcRetryHandler()
    }
    
    func getData() -> Promise<Void> {
        return Promise { seal in
            firstly {
                self.getPreferences()
            }.then {
                self.getCompanies()
            }.then {
                self.getProfile()
            }.then {
                self.getExpenses()
            }.then {
                self.getShifts()
            }.done {
                UserDefaults.standard.set(true, forKey: "allDataOk")
                
                seal.fulfill(())
            }.catch { error in
                UserDefaults.standard.removeObject(forKey: "allDataOk")
                
                seal.reject(error)
            }
        }
    }
    
    private func createRequest(_ path: String, method: HTTPMethod, parameters: Parameters) -> Promise<Any> {
        let headers = [
            "Authorization": "Bearer \(Auth.auth().currentUser!.uid)",
            "Accept": "application/json"
        ]
        
        let fullUrl = "\(url)/\(path)"
        
        print("\(String(method.rawValue)) \(fullUrl)")
        
        return Promise { seal in
            firstly {
                sessionManager.request(fullUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON()
            }.done { (json, response) in
                seal.fulfill(json)
            }.catch { error in
                print("ERR \(String(method.rawValue)) \(fullUrl)")
                
                seal.reject(error)
            }
        }
    }
    
    private func createRequest(_ path: String, method: HTTPMethod) -> Promise<Any> {
        let parameters: Parameters = [:]
        
        return createRequest(path, method: method, parameters: parameters)
    }
    
    // Preferences
    
    func createPreferences() -> Promise<Void> {
        let parameters: Parameters = [
            "userId": Auth.auth().currentUser!.uid
        ]
        
        return Promise { seal in
            firstly {
                createRequest("preferences", method: .post, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
        
    }
    
    func getPreferences() -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("preferences", method: .get)
            }.done { response in
                guard let json = response as? [String: Any] else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }

                UserDefaults.standard.set(json["goalActive"] as! Bool, forKey: "goalActive")
                if let goalValue = json["goalValue"] as? Double {
                    UserDefaults.standard.set(goalValue, forKey: "goalValue")
                }
                if let online = json["online"] as? Bool {
                    UserDefaults.standard.set(online, forKey: "online")
                } else {
                    UserDefaults.standard.set(false, forKey: "online")
                }
                UserDefaults.standard.set(json["notificationIncome"] as! Bool, forKey: "notificationIncome")
                UserDefaults.standard.set(json["notificationShifts"] as! Bool, forKey: "notificationShifts")
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func setPreference(_ key: String, _ value: Any) -> Promise<Void> {
        let parameters: Parameters = [
            key: value
        ]
        
        return Promise { seal in
            firstly {
                createRequest("preferences", method: .put, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    
    }
    
    // Company
    
    func createCompany(_ company: Company) -> Promise<Void> {
        let parameters: Parameters = [
            "id": company.id!,
            "type": company.type!,
            "name": company.name!,
            "place": company.address!,
            "admin": company.admin!,
            "adminPhone": company.phone!,
            "color": company.color!
        ]
        
        return Promise { seal in
            firstly {
                createRequest("companies", method: .post, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func updateCompany(_ company: Company) -> Promise<Void> {
        let parameters: Parameters = [
            "type": company.type!,
            "name": company.name!,
            "place": company.address!,
            "admin": company.admin!,
            "adminPhone": company.phone!,
            "color": company.color!
        ]
        
        return Promise { seal in
            firstly {
                createRequest("companies/\(company.id!)", method: .put, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getCompanies() -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("companies", method: .get)
            }.done { response in
                guard let json = response as? [[String: Any]] else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                var companies: [String:Data] = [:]
                
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
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func deleteCompany(_ id: String) -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("companies/\(id)", method: .delete)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                    
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // Profile
    
    func createProfile(_ profile: Profile) -> Promise<Void> {
        let parameters: Parameters = [
            "crm": profile.crm!,
            "uf": profile.uf!,
            "graduationDate": profile.graduationDate!,
            "institution": profile.institution!,
            "field": profile.field!
        ]
        
        return Promise { seal in
            firstly {
                createRequest("profile", method: .post, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func updateProfile(_ profile: Profile) -> Promise<Void> {
        let parameters: Parameters = [
            "crm": profile.crm!,
            "uf": profile.uf!,
            "graduationDate": profile.graduationDate!,
            "institution": profile.institution!,
            "field": profile.field!
        ]
        
        return Promise { seal in
            firstly {
                createRequest("profile", method: .put, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                if json["message"] != nil && json["message"] as! String == "Id not found" {
                    return seal.reject(NSError(domain:"", code: 404, userInfo: nil))
                } else {
                    seal.fulfill(())
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getProfile() -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("profile", method: .get)
            }.done { response in
                guard let json = response as? [String: Any] else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                let profile = Profile()
                
                if !json.isEmpty {
                    profile.crm = json["crm"] as! String
                    profile.uf = json["uf"] as! String
                    profile.graduationDate = json["graduationDate"] as! String
                    profile.institution = json["institution"] as! String
                    profile.field = json["field"] as! String
                }
                
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: profile), forKey: "profile")
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // Expenses
    
    func createExpense(_ expense: Expense) -> Promise<Void> {
        var parameters: Parameters = [
            "id": expense.id!,
            "title": expense.title!,
            "value": expense.value!,
            "date": expense.date!
        ]
        
        if expense.groupId != nil {
            parameters["groupId"] = expense.groupId
        }
        
        return Promise { seal in
            firstly {
                createRequest("expenses", method: .post, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func updateExpense(_ expense: Expense) -> Promise<Void> {
        let parameters: Parameters = [
            "id": expense.id!,
            "title": expense.title!,
            "value": expense.value!,
            "date": expense.date!
        ]
        
        return Promise { seal in
            firstly {
                createRequest("expenses/\(expense.id!)", method: .put, parameters: parameters)
            }.done { response in
                guard let json = response as? [String: Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getExpenses() -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("expenses", method: .get)
            }.done { response in
                guard let json = response as? [[String: Any]] else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                    
                var expenses: [String:Data] = [:]
                
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
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func deleteExpense(_ id: String) -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("expenses/\(id)", method: .delete)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func deleteExpenseGroup(_ groupId: String) -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("expenses/group/\(groupId)", method: .delete)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // Shift
    
    func createShift(_ shift: Shift) -> Promise<Void> {
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
        
        return Promise { seal in
            firstly {
                createRequest("shifts", method: .post, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func updateShift(_ shift: Shift) -> Promise<Void> {
        let parameters: Parameters = [
            "companyId": shift.companyId!,
            "date": shift.date!,
            "paid": shift.paid!,
            "paymentDueDate": shift.paymentDueDate!,
            "paymentType": shift.paymentType!,
            "salary": shift.salary!,
            "shiftTime": shift.shiftTime!
        ]
        
        return Promise { seal in
            firstly {
                createRequest("shifts/\(shift.id!)", method: .put, parameters: parameters)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getShifts() -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("shifts", method: .get)
            }.done { response in
                guard let json = response  as? [[String:Any]] else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                var shifts: [String:Data] = [:]
                
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
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func deleteShift(_ id: String) -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("shifts/\(id)", method: .delete)
                }.done { response in
                    guard let json = response as? [String:Any], !json.isEmpty else {
                        return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                    }
                    
                    seal.fulfill(())
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    func deleteShiftGroup(_ groupId: String) -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("shifts/group/\(groupId)", method: .delete)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func deleteShiftsByCompany(_ companyId: String) -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("shifts/company/\(companyId)", method: .delete)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // Util
    
    func deleteAll() -> Promise<Void> {
        return Promise { seal in
            firstly {
                createRequest("all", method: .delete)
            }.done { response in
                guard let json = response as? [String:Any], !json.isEmpty else {
                    return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}

class PdcRetryHandler: RequestRetrier {
    var retryCount = 0
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        
        if error._code == NSURLErrorTimedOut && retryCount < 3 {
            retryCount += 1
            completion(true, 1.0) // retry after 1 second
        } else {
            retryCount = 0
            completion(false, 0.0) // don't retry
        }
    }
}
