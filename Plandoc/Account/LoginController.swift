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
import SwiftKeychainWrapper
import LocalAuthentication
import PromiseKit

class LoginController : UIViewController {
    //MARK: Properties
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    var name: String!
    var email: String!
    var pictureUrl: String!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = KeychainWrapper.standard.string(forKey: "pdcEmail") {
            txtLogin.text = username
        }
        
        if let password = KeychainWrapper.standard.string(forKey: "pdcPassword") {
            txtPassword.text = password
        }
        
        self.hideKeyboardWhenTappedAround()
        
        self.applyBorders()
        
        self.setNavigationBar()
        
        if UserDefaults.standard.bool(forKey: "biometrics") && checkUserAndPass() {
            self.authenticationWithTouchID()
        }
        
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
            let user = self.txtLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let pass = self.txtPassword.text!
            
            initLogin(user, pass)
        }
    }
    
    private func initLogin(_ user: String, _ pass: String) {
        Auth.auth().signIn(withEmail: user, password: pass) { (user, error) in
            
            self.doLogin(user, error)
        }
    }
    
    private func saveCredentialsAndGoToCalendar(pdcUser: User) {
        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
        UserDefaults.standard.set(encoded, forKey: "loggedUser")
        
        firstly {
            DataAccess.instance.getData()
        }.done {
            self.performSegue(withIdentifier: "SegueLoginToMenu", sender: self)
        }.catch { error in
            print(error)
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
            case .success:
                var name = "", email = "", pictureUrl = ""
                
                self.presentAlert()
                
                if((FBSDKAccessToken.current()) != nil) {
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                        if (error == nil) {
                            let dict = result as! [String : AnyObject]
                            name = dict["name"] as! String
                            email = dict["email"] as! String
                            
                            if let picture = dict["picture"] as? [String : AnyObject] {
                                if let data = picture["data"] as? [String : AnyObject] {
                                    pictureUrl = (data["url"] as? String)!
                                }
                            }
                            
                            self.trySignInFirebase(name, email, pictureUrl)
                        }
                    })
                }
            }
        })
    }
    
    private func trySignInFirebase(_ name: String, _ email: String, _ pictureUrl: String) {
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
                    self.pictureUrl = pictureUrl
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
                        
                        KeychainWrapper.standard.set(pdcUser.email, forKey: "pdcEmail")
                        
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
        KeychainWrapper.standard.set(self.txtLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "pdcEmail")
            KeychainWrapper.standard.set(self.txtPassword.text!, forKey: "pdcPassword")
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
            
            self.dismissCustomAlert()
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueSignupToPassword" {
            let vc = segue.destination as! SignupPasswordController
            vc.name = self.name
            vc.email = self.email
            vc.pictureUrl = self.pictureUrl
        }
    }
    
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Usar Passcode"
        
        var authError: NSError?
        let reasonString = "Para acessar o aplicativo"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    let user = KeychainWrapper.standard.string(forKey: "pdcEmail")
                    let pass = KeychainWrapper.standard.string(forKey: "pdcPassword")
                    self.initLogin(user!, pass!)
                    
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    private func checkUserAndPass() -> Bool {
        return KeychainWrapper.standard.string(forKey: "pdcEmail") != nil &&
            KeychainWrapper.standard.string(forKey: "pdcPassword") != nil
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}
