//
//  SignupPasswordController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 27/03/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper
import FirebaseStorage

class SignupPasswordController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    
    var email: String!
    var name: String!
    var pictureUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtPassword.delegate = self
        txtPassword.applyBottomBorder()
        
        self.hideKeyboardWhenTappedAround()
        
        self.setNavigationBar()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        btnNext.isEnabled = text.count >= 6
        
        return true
    }
    
    @IBAction func goToPhone(_ sender: Any) {
        txtPassword.resignFirstResponder()
        
        self.presentAlert()
        
        let user = Auth.auth().currentUser!
        
        let emailCredential = EmailAuthProvider.credential(withEmail: self.email, password: txtPassword.text!)
        
        user.link(with: emailCredential, completion: { (user, err) in
            let changeRequest = user?.createProfileChangeRequest()
            changeRequest?.displayName = self.name
            changeRequest?.commitChanges { error in
                if let error = error {
                    print(error)
                    
                    self.dismissCustomAlert()
                } else {
                    let pdcUser = User()
                    pdcUser.id = user?.uid
                    pdcUser.email = self.email
                    pdcUser.name = self.name
                    
                    if self.pictureUrl != nil && self.pictureUrl != "" {
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig)
                        let request = URLRequest(url: URL(string: self.pictureUrl)!)
                        let task = session.dataTask(with: request) { (data, response, error) in
                            let storage = Storage.storage()
                            let ref = storage.reference().child("\(user!.uid)/profile.jpg")
                            
                            ref.putData(data!, metadata: nil) { (metadata, error) in
                                pdcUser.picture = data
                                
                                self.archiveData(pdcUser)
                            }
                        }
                        task.resume()
                    } else {
                        self.archiveData(pdcUser)
                    }
                }
            }
        })
    }
    
    private func archiveData(_ pdcUser: User) {
        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
        UserDefaults.standard.set(encoded, forKey: "activation")
        
        
        KeychainWrapper.standard.set(self.email, forKey: "pdcEmail")
        KeychainWrapper.standard.set(self.txtPassword.text!, forKey: "pdcPassword")
        
        self.performSegue(withIdentifier: "SeguePasswordToPhone", sender: self)
    }
    
    @IBAction func showOrHidePassword(_ sender: UIButton) {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        
        if txtPassword.isSecureTextEntry {
            sender.setImage(UIImage(named: "RevealPasswordIcon"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "HidePasswordIcon"), for: .normal)
        }
    }
}
