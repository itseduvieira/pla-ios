//
//  Company.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 06/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import Foundation

class Company: NSObject, NSCoding {
    var id: String!
    var name: String!
    var address: String!
    var phone: String!
    var admin: String!
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        id = decoder.decodeObject(forKey: "id") as? String
        name = decoder.decodeObject(forKey: "name") as? String
        address = decoder.decodeObject(forKey: "address") as? String
        phone = decoder.decodeObject(forKey: "phone") as? String
        admin = decoder.decodeObject(forKey: "admin") as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(admin, forKey: "admin")
    }
}

