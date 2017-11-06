//
//  ShiftController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class ShiftController : UIViewController {
    //MARK: Properties
    @IBOutlet weak var imgPicture: UIImageView!
    
    weak var sender: UIViewController!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func save() {
        UserDefaults.standard.set("test", forKey: "shifts")
        
        self.performSegue(withIdentifier: "SegueShiftsToFirstSteps", sender: self)
    }
}

