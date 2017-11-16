//
//  AccountController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 09/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
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
        let user = Auth.auth().currentUser
        txtName.text = user?.displayName
        txtPhone.text = user?.phoneNumber
        txtEmail.text = user?.email
        txtPassword.text = UserDefaults.standard.string(forKey: "password")
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let doneItem = UIBarButtonItem(title: "Salvar", style: .plain, target: self, action: #selector(save))
        navItem.rightBarButtonItem = doneItem
    }
    
    @objc func save() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueAccountToProfile") {
            let vc = segue.destination as! ProfileController
            vc.sender = self
        }
    }
}
