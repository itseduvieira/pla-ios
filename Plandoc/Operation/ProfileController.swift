//
//  ProfileController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class ProfileController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtCRM: UITextField!
    @IBOutlet weak var txtUF: UITextField!
    @IBOutlet weak var txtGraduationDate: UITextField!
    @IBOutlet weak var txtGraduation: UITextField!
    @IBOutlet weak var txtField: UITextField!
    
    weak var sender: UIViewController!
    
    let imagePicker = UIImagePickerController()
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
        imgProfile.clipsToBounds = true
        
        imgProfile.layer.borderWidth = 3.0;
        imgProfile.layer.borderColor = UIColor(hexString: "#1D9DD5").cgColor
        
        imagePicker.delegate = self
        
        txtCRM.applyBottomBorder()
        txtUF.applyBottomBorder()
        txtGraduationDate.applyBottomBorder()
        txtGraduation.applyBottomBorder()
        txtField.applyBottomBorder()
        
        self.hideKeyboardWhenTappedAround()
        
        //Add done button to numeric pad keyboard
        let toolbarDoneCRM = UIToolbar.init()
        toolbarDoneCRM.sizeToFit()
        var barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(ProfileController.doneToolbarCRM(_:)))
        
        toolbarDoneCRM.items = [barBtnDone]
        txtCRM.inputAccessoryView = toolbarDoneCRM
        
        let toolbarDoneGraduation = UIToolbar.init()
        toolbarDoneGraduation.sizeToFit()
        barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(ProfileController.doneToolbarGraduation(_:)))
        
        toolbarDoneGraduation.items = [barBtnDone]
        txtGraduationDate.inputAccessoryView = toolbarDoneGraduation
        
        UITextField.connectFields(fields: [txtCRM, txtUF, txtGraduationDate, txtGraduation, txtField])
    }
    
    @objc func doneToolbarCRM(_ sender: UITextField) {
        txtUF.becomeFirstResponder()
    }
    
    @objc func doneToolbarGraduation(_ sender: UITextField) {
        txtGraduation.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        txtCRM?.becomeFirstResponder()
    }
    
    @IBAction func save() {
        UserDefaults.standard.set("test", forKey: "profile")
        
        cancel()
    }
    
    @IBAction func choosePicture() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueProfileToFirstSteps", sender: self)
        }
    }
    
    @IBAction func openPicker(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(ProfileController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        txtGraduationDate.text = dateFormatter.string(for: sender.date)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgProfile.contentMode = .scaleAspectFit
            imgProfile.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
