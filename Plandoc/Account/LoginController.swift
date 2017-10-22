//
//  LoginController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 12/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class LoginController : UIViewController {
    //MARK: Properties
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func login() {
        let sb = UIStoryboard(name: "Profile", bundle:nil)
        self.present(sb.instantiateViewController(withIdentifier: "ProfileViewController"), animated: true, completion: nil)
    }
}
