//
//  SignupCodeController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 17/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupCodeController : UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var txtCode: UITextField!
    
    var verificationID: String!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtCode.delegate = self
        txtCode.applyBottomBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        txtCode?.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if text.characters.count == 6 {
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: self.verificationID,
                verificationCode: text)
            
            Auth.auth().currentUser?.link(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                } else {
                    if let data = UserDefaults.standard.object(forKey: "activation") as? NSData,
                        let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? User {
                        pdcUser.phoneValid = true
                        
                        let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                        UserDefaults.standard.set(encoded, forKey: "activation")
                        
                        Auth.auth().sendPasswordReset(withEmail: (user?.email)!) { (error) in
                            let when = DispatchTime.now() + 0.1
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                self.performSegue(withIdentifier: "SegueCodeToFirstSteps", sender: self)
                            }
                        }
                    }
                }
            }
        }
        
        return text.characters.count < 7
    }
}
