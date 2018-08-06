//
//  AccountController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 09/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import SwiftKeychainWrapper

class AccountController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //MARK: Properties
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var constraintHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintTxtName: NSLayoutConstraint!
    
    @IBAction func unwindToAccount(segue: UIStoryboardSegue) {}
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        self.setupPictureRound()
        
        self.applyBorders()
        
        imagePicker.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        UITextField.connectFields(fields: [txtName, txtPhone, txtEmail, txtPassword])
        
        self.loadExistingData()
        
        if UIScreen.main.bounds.height < 500 {
            self.adjust4s()
        }
    }
    
    private func adjust4s() {
        imgPicture.isHidden = true
        constraintHeader.constant = 64
        constraintTxtName.constant = 70
    }
    
    @IBAction func choosePicture() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imgPicture.contentMode = .scaleAspectFill
            imgPicture.image = pickedImage
        } else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgPicture.contentMode = .scaleAspectFill
            imgPicture.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func applyBorders() {
        txtName.applyBottomBorder()
        txtPhone.applyBottomBorder()
        txtEmail.applyBottomBorder()
        txtPassword.applyBottomBorder()
    }
    
    private func setupPictureRound() {
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
            imgPicture.layer.borderWidth = 3;
            imgPicture.layer.borderColor = UIColor(hexString: "#FFFFFF").cgColor
    }
    
    private func loadExistingData() {
        guard let user = UserDefaults.standard.object(forKey: "loggedUser") else {
            return
        }
        
        let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: user as! Data) as! User
        
        txtName.text = pdcUser.name
        txtPhone.text = pdcUser.phone
        txtEmail.text = pdcUser.email
        txtPassword.text = KeychainWrapper.standard.string(forKey: "pdcPassword")
        if let img = pdcUser.picture {
            imgPicture.image = UIImage(data: img)
        }
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let doneItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(save))
        navItem.rightBarButtonItem = doneItem
        let calendarTypeItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = calendarTypeItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueUnwindToExtendedMenu", sender: self)
    }
    
    @objc func save() {
        let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "loggedUser") as! Data) as! User
        
        if let user = Auth.auth().currentUser {
            self.presentAlert()
            
            let changeRequest = user.createProfileChangeRequest()
            
            if txtName.text! != user.displayName {
                changeRequest.displayName = txtName.text!
                
                pdcUser.name = changeRequest.displayName
            }
            
            let data = UIImageJPEGRepresentation(imgPicture.image!, 1.0)
            
            if pdcUser.picture != data {
                let storage = Storage.storage()
                let ref = storage.reference().child("\(user.uid)/profile.jpg")
                
                ref.putData(data!, metadata: nil) { (metadata, error) in
                    if let error = error {
                        self.showError(error)
                    } else {
                        pdcUser.picture = data
                    }
                }
            }
            
            if txtEmail.text! != user.email {
                user.updateEmail(to: txtEmail.text!, completion: { error in
                    if let error = error {
                        self.showError(error)
                    } else {
                        pdcUser.email = self.txtEmail.text!
                    }
                })
            }
            
            changeRequest.commitChanges { (error) in
                if let error = error {
                    self.showError(error)
                } else {
                    let currentPassword = KeychainWrapper.standard.string(forKey: "pdcPassword")
                    if self.txtPassword.text!.count >= 6 {
                        if self.txtPassword.text! != currentPassword {
                            let credential = EmailAuthProvider.credential(withEmail: pdcUser.email, password: currentPassword!)
                            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
                                if let error = error {
                                    self.showError(error)
                                } else {
                                    user.updatePassword(to: self.txtPassword.text!) { (error) in
                                        if let error = error {
                                            self.showError(error)
                                        } else {
                                            KeychainWrapper.standard.set(self.txtPassword.text!, forKey: "pdcPassword")
                                            
                                            self.showSuccess(pdcUser)
                                        }
                                    }
                                }
                            })
                        } else {
                            self.showSuccess(pdcUser)
                        }
                    } else {
                        self.dismissCustomAlert()
                        
                        let alertController = UIAlertController(title: "Erro ao salvar o perfil", message: "A senha deve conter ao menos 6 caracteres.", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func showSuccess(_ pdcUser: User) {
        self.dismissCustomAlert()
        
        let archivedUser = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
        UserDefaults.standard.set(archivedUser, forKey: "loggedUser")
        
        self.showMsg(msg: "Seu perfil foi salvo com sucesso ;)")
    }
    
    private func showError(_ error: Error) {
        self.dismissCustomAlert()
        
        print(error)
        
        let alertController = UIAlertController(title: "Dados Pessoais", message: "Erro ao salvar o Perfil. Verifique sua conexão com a Internet e tente novamente.", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func showOrHidePassword(_ sender: UIButton) {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        
        if txtPassword.isSecureTextEntry {
            sender.setImage(UIImage(named: "RevealPasswordIcon"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "HidePasswordIcon"), for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueAccountToProfile") {
            let vc = segue.destination as! ProfileController
            vc.sender = self
        }
    }
}
