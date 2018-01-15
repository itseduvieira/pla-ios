//
//  ForgotPasswordController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 18/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var txtEmail: UITextField!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.setNavigationBar()
        
        txtEmail.applyBottomBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueForgotToLogin", sender: self)
    }
    
    @IBAction func sendRecover() {
        if txtEmail.text == nil || txtEmail.text == "" {
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: txtEmail.text!, completion: {error in
            var txt = "Um email foi enviado para \(self.txtEmail.text!)."
            
            if let error = error {
                txt = error.localizedDescription
            }
            
            let alertController = UIAlertController(title: "Esqueci a senha", message: txt, preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: {
                self.txtEmail.text = ""
            })
        })
    }
}
