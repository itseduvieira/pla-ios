//
//  CompanyController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import ChromaColorPicker

class CompanyController : UIViewController, ChromaColorPickerDelegate {
    //MARK: Properties
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtAdmin: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var selectedColor: UIView!
    
    weak var sender: UIViewController!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.hideKeyboardWhenTappedAround()
        
        self.applyBorders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showColorAlert()
    }
    
    @IBAction func save() {
        UserDefaults.standard.set("test", forKey: "companies")
        
        self.performSegue(withIdentifier: "SegueCompanyToFirstSteps", sender: self)
    }
    
    @IBAction func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueCompanyToFirstSteps", sender: self)
        }
    }
    
    private func setupPictureRound() {
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
        imgProfile.clipsToBounds = true
        
        //        imgProfile.layer.borderWidth = 2.0;
        //        imgProfile.layer.borderColor = UIColor(hexString: "#1D9DD5").cgColor
    }
    
    private func applyBorders() {
        txtCompany.applyBottomBorder()
        txtAddress.applyBottomBorder()
        txtAdmin.applyBottomBorder()
        txtPhone.applyBottomBorder()
    }
    
    private func showColorAlert() {
        let neatColorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        neatColorPicker.delegate = self //ChromaColorPickerDelegate
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
        neatColorPicker.hexLabel.textColor = UIColor.white
        
        let alertController = UIViewController()
        alertController.view.backgroundColor = UIColor.white
        alertController.view.addSubview(neatColorPicker)
        
        alertController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(alertController, animated: true, completion: nil)
    }
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
    }
}
