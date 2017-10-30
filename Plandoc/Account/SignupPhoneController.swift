//
//  SignupPhoneController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 16/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupPhoneController : UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var btnVerify: UIButton!
    
    private var verificationID: String!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = UserDefaults.standard.string(forKey: "name")?.split(separator: " ").first
        txtTitle.text = txtTitle.text!.replacingOccurrences(of: "%s", with: String(name!))
        
        txtPhone.delegate = self
        txtPhone.applyBottomBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        txtPhone?.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        btnVerify.isEnabled = text.characters.count >= 11
        
        return true
    }
    
    @IBAction func verifyPhone() {
        var phone = txtPhone.text!
        
        if !phone.starts(with: "+55") {
            phone = "+55" + phone
        }
        
        UserDefaults.standard.set(phone, forKey: "phone")
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.verificationID = verificationID
            self.performSegue(withIdentifier: "SeguePhoneToCode", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController2 = segue.destination as? SignupCodeController {
            viewController2.verificationID = self.verificationID
        }
    }
}
