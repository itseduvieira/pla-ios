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
    @IBOutlet weak var colorIndicator: UIView!
    @IBOutlet weak var switchFixo: UISwitch!
    @IBOutlet weak var btnPaid: UIRoundedButton!
    
    weak var sender: UIViewController!
    var id: String!
    
    var past: Bool! = false
    
    var picker: UIPickerView!
    
    var companiesData: [Data]!
    var shiftTimeData = ["6 Horas", "12 Horas"]
    var paymentTypeData = ["A Vista", "Final do Mês Atual", "Final do Próximo Mês", "Após 1 Semana", "Após 2 Semanas", "Após 3 Semanas"]
    var companyChoosed: Company!
    
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
        
        self.hideKeyboardWhenTappedAround()
        
        self.setNavigationBar()
        
        let dictCompanies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] ?? [:]
        
        self.companiesData = [Data](dictCompanies.values)
        
        UITextField.connectFields(fields: [txtCompany, txtDate, txtHour, txtPaymentType, txtShiftTime, txtSalary])
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        
        datePicker.locale = Locale(identifier: "pt_BR")
        txtDate.inputView = datePicker
        timePicker.locale = Locale(identifier: "pt_BR")
        txtHour.inputView = timePicker
        
        self.setupDateField()
        
        self.setupTimeField()
        
        self.loadExistingData()
        
        if self.id != nil {
            var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
            let shift = NSKeyedUnarchiver.unarchiveObject(with: shifts[id]!) as! Shift
            if !shift.paid {
                btnPaid.isHidden = false
            }
        } else {
            btnPaid.isHidden = true
            self.applyBorders()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if companiesData.isEmpty {
            let alertController = UIAlertController(title: "Nenhuma Empresa Cadastrada", message: "Para cadastrar um plantão, primeiro você deve cadastrar uma empresa.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Entendi", style: .cancel, handler: {(action: UIAlertAction!) in
                self.performSegue(withIdentifier: "SegueShiftToCompany", sender: self)
            })
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueShiftToCompany" {
            let vc = segue.destination as! CompanyController
            vc.sender = self
        }
    }
    
    @objc func save() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        var date = formatter.date(from: "\(self.txtDate.text!) \(self.txtHour.text!)")
        
        if switchFixo.isOn {
            let groupId = String.random()
            for _ in 0...30 {
                saveOne(groupId, date: date!)
                
                let minute:TimeInterval = 60.0
                let hour:TimeInterval = 60.0 * minute
                let day:TimeInterval = 24 * hour
                let week: TimeInterval = 7 * day
                date?.addTimeInterval(week)
            }
        } else {
            saveOne(nil, date: date!)
        }
        
        cancel()
    }
    
    private func saveOne(_ groupId: String?, date: Date) {
        var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
        
        let pdcShift = Shift()
        pdcShift.groupId = groupId
        pdcShift.id = String.random()
        pdcShift.salary = Double(txtSalary.text!)
        pdcShift.company = companyChoosed
        pdcShift.date = date
        pdcShift.paymentType = txtPaymentType.text!
        pdcShift.shiftTime = txtShiftTime.text!.contains("6") ? 6 : 12
        pdcShift.paid = false
        
        let minute:TimeInterval = 60.0
        let hour:TimeInterval = 60.0 * minute
        let day:TimeInterval = 24 * hour
        let oneWeek: TimeInterval = 7 * day
        let twoWeeks: TimeInterval = 2 * oneWeek
        let threeWeeks: TimeInterval = 3 * oneWeek
        
        pdcShift.paymentDueDate = pdcShift.date
        
        if pdcShift.paymentType == "Final do Mês Atual" {
            pdcShift.paymentDueDate = pdcShift.date
        } else if pdcShift.paymentType == "Final do Próximo Mês" {
            pdcShift.paymentDueDate = pdcShift.date
        } else if pdcShift.paymentType == "Após 1 semana" {
            pdcShift.paymentDueDate = pdcShift.date.addingTimeInterval(oneWeek)
        } else if pdcShift.paymentType == "Após 2 semana" {
            pdcShift.paymentDueDate = pdcShift.date.addingTimeInterval(twoWeeks)
        } else if pdcShift.paymentType == "Após 3 semana" {
            pdcShift.paymentDueDate = pdcShift.date.addingTimeInterval(threeWeeks)
        }
        
        let shift = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
        shifts[pdcShift.id] = shift
        UserDefaults.standard.set(shifts, forKey: "shifts")
    }
    
    @objc func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueShiftsToFirstSteps", sender: self)
        } else if self.sender.restorationIdentifier == "CalendarViewController" {
            self.performSegue(withIdentifier: "SegueShiftToCalendar", sender: self)
        } else if self.sender.restorationIdentifier == "CompanyViewController" {
            self.performSegue(withIdentifier: "SegueShiftToCompanyCalendar", sender: self)
        }
    }
    
    @IBAction func pay() {
        var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
        let pdcShift = NSKeyedUnarchiver.unarchiveObject(with: shifts[id]!) as! Shift
        pdcShift.paid = true
        let shift = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
        shifts[pdcShift.id] = shift
        UserDefaults.standard.set(shifts, forKey: "shifts")
        cancel()
    }
    
    @IBAction func enterDate() {
        if (txtDate.text?.isEmpty)! {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            
            txtDate.text = formatter.string(from: Date())
        }
    }
    
    @IBAction func enterTime() {
        if (txtHour.text?.isEmpty)! {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            txtHour.text = formatter.string(from: Date())
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
        if false {
            navBar.barTintColor = UIColor(hexString: "#E93F33")
        } else {
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
        }
        
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(cancel))
        navItem.leftBarButtonItem = backItem
        if self.id == nil {
            let doneItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(save))
            navItem.rightBarButtonItem = doneItem
        }
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
        } else if txtShiftTime.isFirstResponder {
            return shiftTimeData.count
        } else if txtPaymentType.isFirstResponder {
            return paymentTypeData.count
        }
        
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if txtCompany.isFirstResponder {
            let company = NSKeyedUnarchiver.unarchiveObject(with: companiesData[row]) as! Company
            return "\(company.type!) \(company.name!)"
        } else if txtShiftTime.isFirstResponder {
            return shiftTimeData[row]
        } else if txtPaymentType.isFirstResponder {
            return paymentTypeData[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if txtCompany.isFirstResponder {
            let company = NSKeyedUnarchiver.unarchiveObject(with: companiesData[row]) as! Company
            self.companyChoosed = company
            colorIndicator.backgroundColor = UIColor(hexString: company.color)
            txtCompany.text = "\(company.type!) \(company.name!)"
        } else if txtShiftTime.isFirstResponder {
            txtShiftTime.text = shiftTimeData[row]
        } else if txtPaymentType.isFirstResponder {
            txtPaymentType.text = paymentTypeData[row]
        }
    }
    
    @objc func doneClick() {
        if txtCompany.isFirstResponder {
            txtDate.becomeFirstResponder()
        } else if txtShiftTime.isFirstResponder {
            txtSalary.becomeFirstResponder()
        } else if txtPaymentType.isFirstResponder {
            txtShiftTime.becomeFirstResponder()
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
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        txtDate.text = formatter.string(from: sender.date)
    }
    
    @objc func timePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        txtHour.text = formatter.string(from: sender.date)
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
        txtPaymentType.becomeFirstResponder()
    }
    
    private func loadExistingData() {
        if let id = self.id {
            var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
            let shift = NSKeyedUnarchiver.unarchiveObject(with: shifts[id]!) as! Shift
            txtCompany.text = shift.company.name
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            txtDate.text = formatter.string(from: shift.date)
            formatter.dateFormat = "HH:mm"
            txtHour.text = formatter.string(from: shift.date)
            switchFixo.isOn = shift.groupId != nil
            txtPaymentType.text = shift.paymentType
            txtShiftTime.text = shift.shiftTime == 6 ? "6 Horas" : "12 Horas"
            txtSalary.text = String(shift.salary)
            colorIndicator.backgroundColor = UIColor(hexString: shift.company.color)
        }
    }
}

