//
//  ShiftController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class ShiftController : UIViewController {
    //MARK: Properties
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtHour: UITextField!
    @IBOutlet weak var txtShiftTime: UITextField!
    @IBOutlet weak var txtPaymentType: UITextField!
    @IBOutlet weak var txtSalary: UITextField!
    
    weak var sender: UIViewController!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.applyBorders()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func save() {
        var shifts: Array<Data>
        
        if let shiftsSaved = UserDefaults.standard.array(forKey: "shifts") as? Array<Data> {
            shifts = shiftsSaved
        } else {
            shifts = Array()
        }
        
        let pdcShift = Shift()
//        pdcShift.name = txtCompany.text
//        pdcShift.address = txtAddress.text
//        pdcShift.admin = txtAdmin.text
//        pdcShift.phone = txtPhone.text
        
        let shift = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
        shifts.append(shift)
        UserDefaults.standard.set(shifts, forKey: "shifts")
        
        cancel()
    }
    
    @IBAction func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueShiftsToFirstSteps", sender: self)
        }
    }
    
    private func applyBorders() {
        txtCompany.applyBottomBorder()
        txtDate.applyBottomBorder()
        txtHour.applyBottomBorder()
        txtShiftTime.applyBottomBorder()
        txtPaymentType.applyBottomBorder()
        txtSalary.applyBottomBorder()
    }
    
    private func setupPictureRound() {
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
    }
}

