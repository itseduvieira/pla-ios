//
//  LoginController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 12/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginController : UIViewController {
    //MARK: Properties
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
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
        
        self.setNavigationBar()
        
        UITextField.connectFields(fields: [txtLogin, txtPassword])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func login() {
        if self.txtLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.txtPassword.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Preencha os campos de email e senha.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().signIn(withEmail: self.txtLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: self.txtPassword.text!) { (user, error) in
                
                if error == nil {
                    UserDefaults.standard.set(self.txtLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "username")
                    UserDefaults.standard.set(self.txtPassword.text!, forKey: "password")
                    if let user = user {
                        let pdcUser = User(id: user.uid, name: user.displayName!, email: user.email!, phone: user.phoneNumber!)
                        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                        UserDefaults.standard.set(encoded, forKey: "loggedUser")
                    }
                    
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
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueLoginToSignup", sender: self)
    }
    
    @IBAction func showOrHidePass(_ sender: UIButton) {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
    }
}
