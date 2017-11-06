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
        } else if let data = UserDefaults.standard.object(forKey: "activation") as? NSData,
                let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? User {
            if pdcUser.phoneValid != nil && pdcUser.phoneValid {
                self.performSegue(withIdentifier: "SegueSignupToFirstSteps", sender: self)
            } else if pdcUser.name != nil {
                self.performSegue(withIdentifier: "SegueSignupToPhone", sender: self)
            }
        } else {
            view.isHidden = false
        }
    }
}
