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
    var type: String!
    var name: String!
    var address: String!
    var phone: String!
    var admin: String!
    var color: String!
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        type = decoder.decodeObject(forKey: "type") as? String
        id = decoder.decodeObject(forKey: "id") as? String
        name = decoder.decodeObject(forKey: "name") as? String
        address = decoder.decodeObject(forKey: "address") as? String
        phone = decoder.decodeObject(forKey: "phone") as? String
        admin = decoder.decodeObject(forKey: "admin") as? String
        color = decoder.decodeObject(forKey: "color") as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: "type")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(admin, forKey: "admin")
        aCoder.encode(color, forKey: "color")
    }
}

