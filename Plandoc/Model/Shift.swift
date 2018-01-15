//
//  Shift.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 02/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import Foundation

class Shift: NSObject, NSCoding {
    var id: String!
    var groupId: String!
    var company: Company!
    var date: Date!
    var paymentType: String!
    var shiftTime: Int!
    var paymentDueDate: Date!
    var salary: Double!
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        id = decoder.decodeObject(forKey: "id") as? String
        groupId = decoder.decodeObject(forKey: "groupId") as? String
        company = decoder.decodeObject(forKey: "company") as? Company
        date = decoder.decodeObject(forKey: "date") as? Date
        paymentType = decoder.decodeObject(forKey: "paymentType") as? String
        shiftTime = decoder.decodeObject(forKey: "shiftTime") as? Int
        paymentDueDate = decoder.decodeObject(forKey: "paymentDueDate") as? Date
        salary = decoder.decodeObject(forKey: "salary") as? Double
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(groupId, forKey: "groupId")
        aCoder.encode(company, forKey: "company")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(paymentType, forKey: "paymentType")
        aCoder.encode(shiftTime, forKey: "shiftTime")
        aCoder.encode(paymentDueDate, forKey: "paymentDueDate")
        aCoder.encode(salary, forKey: "salary")
    }
}

