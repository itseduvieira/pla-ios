//
//  LoginController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 12/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController : UIViewController {
    //MARK: Properties
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            txtLogin.text = username
        }
        
        if let password = UserDefaults.standard.string(forKey: "password") {
            txtPassword.text = password
        }
        
        self.hideKeyboardWhenTappedAround()
        
        self.applyBorders()
        
        UITextField.connectFields(fields: [txtLogin, txtPassword])
    }
    
    @IBAction func login() {
        if self.txtLogin.text == "" || self.txtPassword.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Preencha os campos de email e senha.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().signIn(withEmail: self.txtLogin.text!, password: self.txtPassword.text!) { (user, error) in
                
                if error == nil {
                UserDefaults.standard.set(self.txtLogin.text!, forKey: "username")
                UserDefaults.standard.set(self.txtPassword.text!, forKey: "password")
                    
                    self.performSegue(withIdentifier: "SegueLoginToMenu", sender: self)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func applyBorders() {
        txtLogin.applyBottomBorder()
        txtPassword.applyBottomBorder()
    }
}
