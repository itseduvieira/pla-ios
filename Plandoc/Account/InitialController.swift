//
//  InitialController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 23/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FBSDKCoreKit
import FacebookCore
import FacebookLogin

class InitialController : UIViewController {
    //MARK: Properties
    @IBAction func unwindToSignup(segue: UIStoryboardSegue) {}
    
    var name: String!
    var email: String!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let data = UserDefaults.standard.object(forKey: "activation") as? NSData,
                let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? User {
            if pdcUser.phoneValid != nil && pdcUser.phoneValid {
                self.performSegue(withIdentifier: "SegueSignupToFirstSteps", sender: self)
            } else if pdcUser.name != nil {
                self.performSegue(withIdentifier: "SegueSignupToPhone", sender: self)
            }
        } else if Auth.auth().currentUser != nil {
            if UserDefaults.standard.object(forKey: "loggedUser") == nil {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("Error at signOut")
                }
                
                for v in view.subviews {
                    v.isHidden = false
                }
            } else {
                self.performSegue(withIdentifier: "SegueSignupToMenu", sender: self)
            }
        } else {
            for v in view.subviews {
                v.isHidden = false
            }
        }
    }
    
    @IBAction func loginWithFB() {
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
                        self.performSegue(withIdentifier: "SegueSignupToPhone", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueSignupToPassword" {
            let vc = segue.destination as! SignupPasswordController
            vc.name = self.name
            vc.email = self.email
        }
    }
    
    private func saveCredentialsAndGoToCalendar(pdcUser: User) {
        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
        UserDefaults.standard.set(encoded, forKey: "loggedUser")
        
        self.performSegue(withIdentifier: "SegueSignupToMenu", sender: self)
    }
}
