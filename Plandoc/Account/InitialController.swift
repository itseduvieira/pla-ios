//
//  InitialController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 23/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class InitialController : UIViewController {
    //MARK: Properties
    
    //MARK: Actions
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser {
            if UserDefaults.standard.object(forKey: "loggedUser") == nil {
                let pdcUser = User(id: user.uid, name: user.displayName!, email: user.email!, phone: user.phoneNumber!)
                let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                UserDefaults.standard.set(encoded, forKey: "loggedUser")
            }
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func loginWithFB() {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { (result, error) in
            if let error = error {
                print(error)
            } else {
                let name = ""
                let email = ""
                let phone = ""
                
                Auth.auth().createUser(withEmail: email, password: String(self.random(6)), completion: { (user: FirebaseAuth.User?, error) in
                    if let error = error {
                        print(error)
                    } else {
                        let changeRequest = user?.createProfileChangeRequest()
                        changeRequest?.displayName = name
                        changeRequest?.commitChanges { error in
                            if let error = error {
                                print(error)
                            } else {
                                let pdcUser = User()
                                pdcUser.id = user?.uid
                                pdcUser.email = email
                                pdcUser.name = name
                                let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                                UserDefaults.standard.set(encoded, forKey: "activation")
                                self.performSegue(withIdentifier: "SegueNameToPhone", sender: self)
                            }
                        }
                    }
                })
            }
        })
    }
    
    func random(_ digitNumber: Int) -> String {
        var number = ""
        for i in 0..<digitNumber {
            var randomNumber = arc4random_uniform(10)
            while randomNumber == 0 && i == 0 {
                randomNumber = arc4random_uniform(10)
            }
            number += "\(randomNumber)"
        }
        return number
    }
}
