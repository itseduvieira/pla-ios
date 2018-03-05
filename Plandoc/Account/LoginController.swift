//
//  LoginController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 12/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FBSDKLoginKit
import FacebookCore
import FacebookLogin

class LoginController : UIViewController {
    //MARK: Properties
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
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
            self.presentAlert()
            Auth.auth().signIn(withEmail: self.txtLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: self.txtPassword.text!) { (user, error) in
                
                self.doLogin(user, error)
            }
        }
    }
    
    private func saveCredentialsAndGoToCalendar(pdcUser: User) {
        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
        UserDefaults.standard.set(encoded, forKey: "loggedUser")
        
        self.performSegue(withIdentifier: "SegueLoginToMenu", sender: self)
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
        self.performSegue(withIdentifier: "SegueUnwindToSignup", sender: self)
    }
    
    @IBAction func showOrHidePass(_ sender: UIButton) {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
    }
    
    @IBAction func loginFacebook() {
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self, completion: { loginResult in
            switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let _, let _, let _):
                    print("Logged in!")
                    
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    
                    Auth.auth().signIn(with: credential) { (user, error) in
                        self.doLogin(user, error)
                    }
            }
        })
    }
    
    private func doLogin(_ user: FirebaseAuth.User?, _ error: Error?) {
        if error == nil {
            UserDefaults.standard.set(self.txtLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "username")
            UserDefaults.standard.set(self.txtPassword.text!, forKey: "password")
            if let user = user {
                let pdcUser = User(id: user.uid, name: user.displayName!, email: user.email!, phone: user.phoneNumber!)
                
                let storage = Storage.storage()
                let ref = storage.reference().child("\(user.uid)/profile.jpg")
                
                ref.getData(maxSize: 8 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                        
                        self.saveCredentialsAndGoToCalendar(pdcUser: pdcUser)
                    } else {
                        pdcUser.picture = data!
                        
                        self.saveCredentialsAndGoToCalendar(pdcUser: pdcUser)
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        self.dismissCustomAlert()
    }
}
