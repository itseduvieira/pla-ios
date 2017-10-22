//
//  SignupController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 16/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class SignupNameController : UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtName.delegate = self
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
        UserDefaults.standard.set(txtName.text, forKey: "name")
        self.performSegue(withIdentifier: "SegueNameToPhone", sender: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        btnNext.isEnabled = !text.isEmpty
        
        return true
    }
}
