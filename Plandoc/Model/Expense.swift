//
//  Expense.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 11/03/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import Foundation

class Expense: NSObject, NSCoding {
    var groupId: String!
    var id: String!
    var title: String!
    var value: Double!
    var date: Date!
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        groupId = decoder.decodeObject(forKey: "groupId") as? String
        id = decoder.decodeObject(forKey: "id") as? String
        title = decoder.decodeObject(forKey: "title") as? String
        value = decoder.decodeObject(forKey: "value") as? Double
        date = decoder.decodeObject(forKey: "date") as? Date
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(groupId, forKey: "groupId")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(value, forKey: "value")
        aCoder.encode(date, forKey: "date")
    }
}
