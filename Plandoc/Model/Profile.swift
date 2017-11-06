//
//  Profile.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 02/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import Foundation

class Profile: NSObject, NSCoding {
    var crm: String!
    var uf: String!
    var graduationDate: String!
    var institution: String!
    var field: String!
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        crm = decoder.decodeObject(forKey: "crm") as? String
        uf = decoder.decodeObject(forKey: "uf") as? String
        graduationDate = decoder.decodeObject(forKey: "graduationDate") as? String
        institution = decoder.decodeObject(forKey: "institution") as? String
        field = decoder.decodeObject(forKey: "field") as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(crm, forKey: "crm")
        aCoder.encode(uf, forKey: "uf")
        aCoder.encode(graduationDate, forKey: "graduationDate")
        aCoder.encode(institution, forKey: "institution")
        aCoder.encode(field, forKey: "field")
    }
}
