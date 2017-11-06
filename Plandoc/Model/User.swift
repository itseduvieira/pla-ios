//
//  User.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 02/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    var id: String!
    var name: String!
    var email: String!
    var phone: String!
    var password: String!
    var phoneValid: Bool! = false
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        id = decoder.decodeObject(forKey: "id") as? String
        name = decoder.decodeObject(forKey: "name") as? String
        email = decoder.decodeObject(forKey: "email") as? String
        phone = decoder.decodeObject(forKey: "phone") as? String
        password = decoder.decodeObject(forKey: "password") as? String
        phoneValid = decoder.decodeObject(forKey: "phoneValid") as? Bool
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(phoneValid, forKey: "phoneValid")
    }
}
