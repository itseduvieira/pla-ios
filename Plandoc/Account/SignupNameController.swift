//
//  SignupController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 16/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupNameController : UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtName.applyBottomBorder()
        
        txtEmail.delegate = self
        txtEmail.applyBottomBorder()
        
        hideKeyboardWhenTappedAround()
        
        UITextField.connectFields(fields: [txtName, txtEmail])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        txtName?.becomeFirstResponder()
    }
    
    @IBAction func goToPhoneVerification() {
        Auth.auth().createUser(withEmail: txtEmail.text!, password: String(random(6)), completion: { (user: FirebaseAuth.User?, error) in
            if let error = error {
                print(error)
                
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
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.displayName = self.txtName.text
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print(error)
                    } else {
                        let pdcUser = User()
                        pdcUser.id = user?.uid
                        pdcUser.email = self.txtEmail.text!
                        pdcUser.name = self.txtName.text!
                        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                        UserDefaults.standard.set(encoded, forKey: "activation")
                        self.performSegue(withIdentifier: "SegueNameToPhone", sender: self)
                    }
                }
            }
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        btnNext.isEnabled = !text.isEmpty && !(txtName.text?.isEmpty)!
        
        return true
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
