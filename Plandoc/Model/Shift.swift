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
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        id = decoder.decodeObject(forKey: "id") as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
    }
}

