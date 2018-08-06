//
//  SignupController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 16/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class SignupNameController : UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtName.delegate = self
        txtName.applyBottomBorder()
        
        txtEmail.delegate = self
        txtEmail.applyBottomBorder()
        
        txtPass.delegate = self
        txtPass.applyBottomBorder()
        
        self.hideKeyboardWhenTappedAround()
        
        self.setNavigationBar()
        
        UITextField.connectFields(fields: [txtName, txtEmail, txtPass])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        txtName?.becomeFirstResponder()
    }
    
    @IBAction func goToPhoneVerification() {
        txtName.resignFirstResponder()
        txtEmail.resignFirstResponder()
        txtPass.resignFirstResponder()
        
        self.presentAlert()
        
        Auth.auth().createUser(withEmail: txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: txtPass.text!, completion: { (userResult, error) in
            if let error = error {
                print(error)
                
                self.dismissCustomAlert()
                
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                        case .invalidEmail, .emailAlreadyInUse:
                            let alert = UIAlertController(title: "Erro", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        default:
                            print("Create User Error: \(errCode)")
                    }
                }
            } else {
                let user = userResult?.user
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.displayName = self.txtName.text
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print(error)
                        
                        self.dismissCustomAlert()
                    } else {
                        
                        self.confirmEmail(user!)
                    }
                }
            }
        })
    }
    
    private func confirmEmail(_ user: FirebaseAuth.User) {
        do {
            let pdcUser = User()
            pdcUser.id = user.uid
            pdcUser.email = self.txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            pdcUser.name = self.txtName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let confirmURL = URL(string: "http://api.plandoc.com.br/v1/confirm")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            var request = URLRequest(url: confirmURL!)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let body: [String:Any] = [
                "name": pdcUser.name,
                "email": pdcUser.email
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if let data = data, error == nil, let response = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
                        KeychainWrapper.standard.set(pdcUser.email, forKey: "pdcEmail")
                        KeychainWrapper.standard.set(self.txtPass.text!, forKey: "pdcPassword")
                        
                        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                        
                        UserDefaults.standard.set(encoded, forKey: "activation")
                        self.performSegue(withIdentifier: "SegueNameToPhone", sender: self)
                    }
                    
                } else {
                    print("Error at confirm email")
                    
                    self.dismissCustomAlert()
                }
            }
            
            task.resume()
        } catch let error {
            print("An error occurred while send report request \(error)")
            
            self.dismissCustomAlert()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = txtPass.text!
        
        if txtPass.isFirstResponder {
            text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        }
        
        btnNext.isEnabled = text.count >= 6 && !txtName.text!.isEmpty && !txtEmail.text!.isEmpty
        
        return true
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueNameToInitial", sender: self)
    }
    
    @IBAction func showOrHidePassword(_ sender: UIButton) {
        txtPass.isSecureTextEntry = !txtPass.isSecureTextEntry
        
        if txtPass.isSecureTextEntry {
            sender.setImage(UIImage(named: "RevealPasswordIcon"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "HidePasswordIcon"), for: .normal)
        }
    }
}
