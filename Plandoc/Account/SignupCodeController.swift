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
        
        if text.count == 6 {
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.txtCode.resignFirstResponder()
            
                self.presentAlert()
            
                let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: self.verificationID,
                verificationCode: text)
            
                Auth.auth().currentUser?.link(with: credential) { (user, error) in
                    if let error = error {
                        print(error)
                    
                        self.dismissCustomAlert()
                    
                        let errCode = AuthErrorCode(rawValue: error._code)!
                    
                        switch errCode {
                        case .invalidVerificationCode:
                            let alertController = UIAlertController(title: "Código Incorreto", message: "O código informado está incorreto.", preferredStyle: .alert)
                        
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        
                            alertController.addAction(defaultAction)
                        
                            self.present(alertController, animated: true, completion: nil)
                            break
                        case .credentialAlreadyInUse:
                            let alertController = UIAlertController(title: "Perfil Existente", message: "Já existe outro usuário utilizando este telefone.", preferredStyle: .alert)
                        
                            let defaultAction = UIAlertAction(title: "Trocar Telefone", style: .default, handler: { action in
                                self.retry()
                            })
                            let cancelAction = UIAlertAction(title: "Cancelar Cadastro", style: .destructive, handler: { action in
                            
                                UserDefaults.standard.removeObject(forKey: "activation")
                            
                                Auth.auth().currentUser?.delete(completion: { (error) in
                                    if let error = error {
                                        print(error)
                                    }
                                
                                    self.performSegue(withIdentifier: "SegueUnwindToSignup", sender: self)
                                })
                            })
                            alertController.addAction(cancelAction)
                            alertController.addAction(defaultAction)
                        
                            self.present(alertController, animated: true, completion: nil)
                            break
                        default:
                            print(error)
                        }
                    } else {
                        if let data = UserDefaults.standard.object(forKey: "activation") as? NSData,
                            let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? User {
                            pdcUser.phoneValid = true
                        
                            let encoded = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                            UserDefaults.standard.set(encoded, forKey: "activation")
                        
                        
                            self.performSegue(withIdentifier: "SegueCodeToFirstSteps", sender: self)
                        }
                    }
                }
            }
        }
        
        return text.count < 7
    }
    
    @IBAction func retry() {
        
        
        self.performSegue(withIdentifier: "SegueCodeToPhone", sender: self)
    }
}
