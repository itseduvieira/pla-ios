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
    
    var name: String!
    var email: String!
    
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
        if txtPassword.isSecureTextEntry {
            sender.setImage(UIImage(named: "RevealPasswordIcon"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "HidePasswordIcon"), for: .normal)
        }
    }
    
    @IBAction func loginFacebook() {
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let _, let _, let _):
                var name = "", email = ""
                
                if((FBSDKAccessToken.current()) != nil) {
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                        if (error == nil) {
                            let dict = result as! [String : AnyObject]
                            name = dict["name"] as! String
                            email = dict["email"] as! String
                            
                            self.trySignInFirebase(name, email)
                        }
                    })
                }
            }
        })
    }
    
    private func trySignInFirebase(_ name: String, _ email: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error)
                
                let errCode = AuthErrorCode(rawValue: error._code)!
                
                switch errCode {
                case .accountExistsWithDifferentCredential:
                    let alertController = UIAlertController(title: "Perfil Existente", message: "Já existe um usuário utilizando este email que não está vinculado em sua conta do Facebook. Entre com email e senha e vincule os perfis.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    break
                default:
                    print(error)
                }
            } else if let user = user {
                if user.providerData.count == 1 &&
                    user.providerData[0].providerID == "facebook.com" {
                    self.name = name
                    self.email = email
                    self.performSegue(withIdentifier: "SegueSignupToPassword", sender: self)
                } else {
                    if user.phoneNumber == nil {
                        let pdcUser = User()
                        pdcUser.id = user.uid
                        pdcUser.email = email
                        pdcUser.name = name
                        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                        UserDefaults.standard.set(encoded, forKey: "activation")
                        self.performSegue(withIdentifier: "SegueLoginToPhone", sender: self)
                    } else {
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
                }
            }
        }
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
            let alertController = UIAlertController(title: "Erro", message: error?.localizedDescription, preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        self.dismissCustomAlert()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueSignupToPassword" {
            let vc = segue.destination as! SignupPasswordController
            vc.name = self.name
            vc.email = self.email
        }
    }
}
