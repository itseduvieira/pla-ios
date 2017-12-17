//
//  ShiftController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class ShiftController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    //MARK: Properties
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtHour: UITextField!
    @IBOutlet weak var txtShiftTime: UITextField!
    @IBOutlet weak var txtPaymentType: UITextField!
    @IBOutlet weak var txtSalary: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    weak var sender: UIViewController!
    
    var picker: UIPickerView!
    
    var companiesData: Array<Data>!
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        return picker
    }()
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.applyBorders()
        
        self.hideKeyboardWhenTappedAround()
        
        self.setNavigationBar()
        
        companiesData = UserDefaults.standard.array(forKey: "companies") as! Array<Data>
        
        UITextField.connectFields(fields: [txtCompany, txtDate, txtHour, txtShiftTime, txtPaymentType, txtSalary])
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        
        txtDate.inputView = datePicker
        txtHour.inputView = timePicker
        
        self.setupDateField()
        
        self.setupTimeField()
    }
    
    @objc func save() {
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
    
    @objc func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueShiftsToFirstSteps", sender: self)
        } else if self.sender.restorationIdentifier == "CalendarViewController" {
            self.performSegue(withIdentifier: "SegueShiftToCalendar", sender: self)
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
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(cancel))
        navItem.leftBarButtonItem = backItem
        let doneItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(save))
        navItem.rightBarButtonItem = doneItem
    }
    
    @IBAction func showPicker(_ sender: UITextField) {
        pickUp(txtField: sender)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if txtCompany.isFirstResponder {
            return companiesData.count
        }
        
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if txtCompany.isFirstResponder {
            let company = NSKeyedUnarchiver.unarchiveObject(with: companiesData[row]) as! Company
            return "\(company.type!) \(company.name!)"
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if txtCompany.isFirstResponder {
            let company = NSKeyedUnarchiver.unarchiveObject(with: companiesData[row]) as! Company
            txtCompany.text = "\(company.type!) \(company.name!)"
        }
    }
    
    @objc func doneClick() {
        if txtCompany.isFirstResponder {
            txtDate.becomeFirstResponder()
        }
    }
    
    func pickUp(txtField: UITextField) {
        self.picker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.picker.delegate = self
        self.picker.dataSource = self
        
        txtField.inputView = self.picker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtField.inputAccessoryView = toolBar
        
        if txtField.text!.isEmpty {
            self.picker.delegate?.pickerView!(self.picker, didSelectRow: 0, inComponent: 0)
        }
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        txtDate.text = dateFormatter.string(for: sender.date)
    }
    
    @objc func timePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.none
        
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        txtHour.text = dateFormatter.string(for: sender.date)
    }
    
    private func setupDateField() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(doneDate))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtDate.inputAccessoryView = toolBar
    }
    
    private func setupTimeField() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(doneTime))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtHour.inputAccessoryView = toolBar
    }
    
    @objc func doneDate() {
        txtHour.becomeFirstResponder()
    }
    
    @objc func doneTime() {
        txtShiftTime.becomeFirstResponder()
    }
}

