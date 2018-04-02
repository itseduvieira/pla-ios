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
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
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
        txtPassword.text = UserDefaults.standard.string(forKey: "password")
        if let img = pdcUser.picture {
            imgPicture.image = UIImage(data: img)
        }
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let doneItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(save))
        navItem.rightBarButtonItem = doneItem
    }
    
    @objc func save() {
        let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "loggedUser") as! Data) as! User
        
        if let user = Auth.auth().currentUser {
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
                    guard let metadata = metadata else {
                        
                        return
                    }
                    
                    pdcUser.picture = data
                    
                    //changeRequest.photoURL = metadata.downloadURL()
                    //print("Picture uploaded at \(metadata.downloadURL()!.absoluteString)")
                }
            }
            
            if txtEmail.text! != user.email {
                user.updateEmail(to: txtEmail.text!, completion: { error in
                    pdcUser.email = self.txtEmail.text!
                })
            }
            
            changeRequest.commitChanges { (error) in
                if let error = error {
                    print(error)
                    
                    let alertController = UIAlertController(title: "Perfil", message: "Erro ao salvar o perfil.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                } else {
                    let archivedUser = NSKeyedArchiver.archivedData(withRootObject: pdcUser)
                    UserDefaults.standard.set(archivedUser, forKey: "loggedUser")
                    
                    let alertController = UIAlertController(title: "Perfil", message: "O Perfil foi salvo com sucesso.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                }
            }
        }
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
