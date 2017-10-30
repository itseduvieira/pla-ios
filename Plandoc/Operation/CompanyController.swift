//
//  CompanyController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class CompanyController : UIViewController {
    //MARK: Properties
    weak var sender: UIViewController!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func save() {
        UserDefaults.standard.set("test", forKey: "companies")
        
        self.performSegue(withIdentifier: "SegueCompanyToFirstSteps", sender: self)
    }
}
