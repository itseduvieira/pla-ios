//
//  InitialController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 23/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class InitialController : UIViewController {
    //MARK: Properties
    
    //MARK: Actions
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.object(forKey: "loggedUser") != nil {
            self.performSegue(withIdentifier: "SegueSignupToMenu", sender: self)
        } else if UserDefaults.standard.bool(forKey: "phoneValid") {
            self.performSegue(withIdentifier: "SegueSignupToFirstSteps", sender: self)
        } else if UserDefaults.standard.string(forKey: "name") != nil {
            self.performSegue(withIdentifier: "SegueSignupToPhone", sender: self)
        } else {
            view.isHidden = false
        }
    }
}
