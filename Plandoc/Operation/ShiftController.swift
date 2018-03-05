//
//  ShiftController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import UserNotifications

class ShiftController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    //MARK: Properties
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtHour: UITextField!
    @IBOutlet weak var txtShiftTime: UITextField!
    @IBOutlet weak var txtPaymentType: UITextField!
    @IBOutlet weak var constraintPaymentType: NSLayoutConstraint!
    @IBOutlet weak var txtSalary: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var colorIndicator: UIView!
    @IBOutlet weak var switchFixo: UISwitch!
    @IBOutlet weak var btnPaid: UIRoundedButton!
    @IBOutlet weak var txtFixo: UITextField!
    @IBOutlet weak var lblFixo: UILabel!
    @IBOutlet weak var notPaidIndicator: UIView!
    @IBOutlet weak var txtPaymentDueDate: UITextField!
    @IBOutlet weak var lblPaymentDueDate: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    weak var sender: UIViewController!
    var id: String!
    
    var past: Bool! = false
    
    var picker: UIPickerView!
    
    var companiesData: [Data]!
    
    var shiftTimeData: [String] = {
        var data: [String] = []
        data.append("1 Hora")
        for index in 2...24 {
            data.append("\(index) Horas")
        }
        return data
    }()
    
    var fixoData: [String] = {
        var data: [String] = []
        data.append("1 Mês")
        for index in 2...24 {
            data.append("\(index) Meses")
        }
        return data
    }()
    
    var paymentTypeData = ["A Vista", "Final do Mês Atual", "Final do Próximo Mês", "Após X Semanas", "A Prazo"]
    var companyChoosed: String!
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    lazy var dueDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        return picker
    }()
    
    var amt: Int = 0
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.hideKeyboardWhenTappedAround()
        
        self.setNavigationBar()
        
        UITextField.connectFields(fields: [txtCompany, txtDate, txtHour, txtPaymentType, txtShiftTime, txtSalary])
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        dueDatePicker.addTarget(self, action: #selector(dueDatePickerValueChanged), for: .valueChanged)
        
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        
        datePicker.locale = Locale(identifier: "pt_BR")
        txtDate.inputView = datePicker
        dueDatePicker.locale = Locale(identifier: "pt_BR")
        txtPaymentDueDate.inputView = dueDatePicker
        timePicker.locale = Locale(identifier: "pt_BR")
        txtHour.inputView = timePicker
        
        self.setupDateField()
        
        self.setupTimeField()
        
        self.loadExistingData()
        
        self.applyBorders()
        
        txtSalary.delegate = self
        txtSalary.placeholder = updateAmount()
    }
    
    @IBAction func changeFixo(_ sender: UISwitch) {
        if sender.isOn {
            txtFixo.isHidden = false
            lblFixo.isHidden = false
            txtFixo.becomeFirstResponder()
            
            if txtPaymentType.text == "A Prazo" {
                txtPaymentType.text = ""
            }
            
            paymentTypeData.removeLast()
        } else {
            txtFixo.isHidden = true
            lblFixo.isHidden = true
            
            paymentTypeData.append("A Prazo")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dictCompanies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] ?? [:]
        
        self.companiesData = [Data](dictCompanies.values).filter({ (data) -> Bool in
            let company = NSKeyedUnarchiver.unarchiveObject(with: data) as! Company
            return company.active
        })
        
        if companiesData.isEmpty && self.id == nil {
            let alertController = UIAlertController(title: "Nenhuma Empresa Cadastrada", message: "Para cadastrar um plantão, primeiro você deve cadastrar uma empresa.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Entendi", style: .cancel, handler: {action in
                self.performSegue(withIdentifier: "SegueShiftsToCompany", sender: self)
            })
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueShiftsToCompany" {
            let vc = segue.destination as! CompanyController
            vc.sender = self
        }
    }
    
    @objc func resolve() {
        let alert = UIAlertController(title: "Resolver Plantão", message: "O pagamento já foi efetuado?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Já Recebi", style: .default, handler: { action in
            self.pay()
        }))
        alert.addAction(UIAlertAction(title: "Não Compareci, Remover", style: .destructive, handler: { action in
            var dict = UserDefaults.standard.dictionary(forKey: "shifts") as! [String:Data]
            dict.removeValue(forKey: self.id)
            
            UserDefaults.standard.set(dict, forKey: "shifts")
            
            self.cancel()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @objc func save() {
        if txtCompany.text! == "" || txtDate.text! == "" || txtHour.text! == "" || txtPaymentType.text! == "" || txtShiftTime.text! == "" || txtSalary.text! == "" || (txtPaymentType.text! == "A Prazo" && txtPaymentDueDate.text! == "") {
            let alertController = UIAlertController(title: "Erro", message: "Preencha corretamente os campos.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            let date = formatter.date(from: "\(self.txtDate.text!) \(self.txtHour.text!)")!
            
            if switchFixo.isOn && !txtFixo.isHidden {
                let weeks = Int(txtFixo.text!.split(separator: " ")[1])! * 4
                let groupId = String.random()
                for index in 0..<weeks {
                    if index == 0 {
                        saveOne(groupId, date: date)
                    } else {
                        saveOne(groupId, date: Calendar.current.date(byAdding: DateComponents(day: 7 * index), to: date)!)
                    }
                }
            } else {
                saveOne(nil, date: date)
            }
            
            cancel()
        }
    }
    
    private func saveOne(_ groupId: String?, date: Date) {
        let center = UNUserNotificationCenter.current()
        
        var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
        
        var pdcShift = Shift()
        
        if let id = self.id {
            pdcShift = NSKeyedUnarchiver.unarchiveObject(with: shifts[id]!) as! Shift
        } else {
            pdcShift.id = String.random()
            pdcShift.companyId = companyChoosed
            pdcShift.groupId = groupId
            pdcShift.paid = false
        }
        
        pdcShift.salary = Double(txtSalary.text!.replacingOccurrences(of: "R$", with: "").replacingOccurrences(of: ".", with: "") .replacingOccurrences(of: ",", with: "."))
        pdcShift.date = date
        pdcShift.paymentType = txtPaymentType.text!
        pdcShift.shiftTime = Int(txtShiftTime.text!.components(separatedBy: " ")[0])
        
        pdcShift.paymentDueDate = pdcShift.date
        
        if pdcShift.paymentType == "Final do Mês Atual" {
            let interval = Calendar.current.dateInterval(of: .month, for: pdcShift.date)
            pdcShift.paymentDueDate = Calendar.current.date(byAdding: DateComponents(day: -1), to: interval!.end)!
        } else if pdcShift.paymentType == "Final do Próximo Mês" {
            let interval = Calendar.current.dateInterval(of: .month, for: Calendar.current.date(byAdding: DateComponents(month: 1), to: pdcShift.date)!)
            pdcShift.paymentDueDate = Calendar.current.date(byAdding: DateComponents(day: -1), to: interval!.end)!
        } else if pdcShift.paymentType.hasPrefix("Após") {
            let weeks = Int(pdcShift.paymentType.components(separatedBy: " ")[1])!
            pdcShift.paymentDueDate = Calendar.current.date(byAdding: DateComponents(day: 7 * weeks), to: pdcShift.date)!
        } else if pdcShift.paymentType == "A Prazo" {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            pdcShift.paymentDueDate = formatter.date(from: txtPaymentDueDate.text!)
        }
        
        print(pdcShift.paymentDueDate)
        
        let dictCompanies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] ?? [:]
        let company = NSKeyedUnarchiver.unarchiveObject(with: dictCompanies[pdcShift.companyId]!) as! Company
        pdcShift.company = company
        
        let shift = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
        shifts[pdcShift.id] = shift
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.scheduleNotification(pdcShift)
            }
        }
        
        UserDefaults.standard.set(shifts, forKey: "shifts")
    }
    
    @objc func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueShiftsToFirstSteps", sender: self)
        } else if self.sender.restorationIdentifier == "CalendarViewController" || self.sender.restorationIdentifier == "CompanyViewController" {
            self.performSegue(withIdentifier: "SegueUnwindToCalendar", sender: self)
        } else if self.sender.restorationIdentifier == "FinanceDetailViewController" {
            self.performSegue(withIdentifier: "SegueUnwindToFinanceDetail", sender: self)
        }
    }
    
    @IBAction func pay() {
        var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
        let pdcShift = NSKeyedUnarchiver.unarchiveObject(with: shifts[id]!) as! Shift
        pdcShift.paid = true
        let shift = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
        shifts[pdcShift.id] = shift
        UserDefaults.standard.set(shifts, forKey: "shifts")
        
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [id])
        center.removePendingNotificationRequests(withIdentifiers: [id])
        
        cancel()
    }
    
    @IBAction func enterDueDate() {
        if (txtPaymentDueDate.text?.isEmpty)! {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            
            txtPaymentDueDate.text = formatter.string(from: Date())
        }
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
        txtPaymentDueDate.applyBottomBorder()
    }
    
    private func setupPictureRound() {
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
    }
    
    func setNavigationBar() {
        var done = "Salvar"
        var sel = #selector(save)
        
        if id != nil {
            var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
            let pdcShift = NSKeyedUnarchiver.unarchiveObject(with: shifts[id]!) as! Shift
            
            if !pdcShift.paid && Calendar.current.date(byAdding: DateComponents(day: 1), to: pdcShift.paymentDueDate)! < Date()  {
                notPaidIndicator.isHidden = false
                navItem.title = "Pgto Pendente"
                done = "Resolver"
                sel = #selector(resolve)
            }
        }
        
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(cancel))
        navItem.leftBarButtonItem = backItem
        let doneItem = UIBarButtonItem(title: done, style: .done, target: self, action: sel)
        navItem.rightBarButtonItem = doneItem
    }
    
    @IBAction func showPicker(_ sender: UITextField) {
        pickUp(txtField: sender)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if txtFixo.isFirstResponder {
            return fixoData.count
        } else if txtCompany.isFirstResponder {
            return companiesData.count
        } else if txtShiftTime.isFirstResponder {
            return shiftTimeData.count
        } else if txtPaymentType.isFirstResponder {
            return paymentTypeData.count
        }
        
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if txtFixo.isFirstResponder {
            return (fixoData[row])
        } else if txtCompany.isFirstResponder {
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
        if txtFixo.isFirstResponder {
            return txtFixo.text = "por \(fixoData[row])"
        } else if txtCompany.isFirstResponder {
            let company = NSKeyedUnarchiver.unarchiveObject(with: companiesData[row]) as! Company
            self.companyChoosed = company.id
            colorIndicator.backgroundColor = UIColor(hexString: company.color)
            txtCompany.text = "\(company.type!) \(company.name!)"
        } else if txtShiftTime.isFirstResponder {
            txtShiftTime.text = shiftTimeData[row]
        } else if txtPaymentType.isFirstResponder {
            txtPaymentType.text = paymentTypeData[row]
            
            txtPaymentDueDate.isHidden = true
            lblPaymentDueDate.isHidden = true
            stepper.isHidden = true
            
            if txtPaymentType.text == "A Prazo" {
                constraintPaymentType.constant = 152
                txtPaymentDueDate.isHidden = false
                lblPaymentDueDate.isHidden = false
            } else if (txtPaymentType.text?.hasPrefix("Após"))! {
                constraintPaymentType.constant = 126
                stepper.isHidden = false
                changeWeeks(self.stepper)
                txtPaymentType.resignFirstResponder()
            } else {
                constraintPaymentType.constant = 16
            }
        }
    }
    
    @objc func doneClick() {
        if txtFixo.isFirstResponder {
            txtPaymentType.becomeFirstResponder()
        } else if txtCompany.isFirstResponder {
            txtDate.becomeFirstResponder()
        } else if txtShiftTime.isFirstResponder {
            txtSalary.becomeFirstResponder()
        } else if txtPaymentType.isFirstResponder {
            if txtPaymentType.text == "A Prazo" {
                txtPaymentDueDate.becomeFirstResponder()
            } else {
                txtShiftTime.becomeFirstResponder()
            }
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
    
    @objc func dueDatePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        txtPaymentDueDate.text = formatter.string(from: sender.date)
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
        txtPaymentDueDate.inputAccessoryView = toolBar
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
        if txtDate.isFirstResponder {
            txtHour.becomeFirstResponder()
        } else if txtPaymentDueDate.isFirstResponder {
            txtShiftTime.becomeFirstResponder()
        }
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
            switchFixo.isEnabled = false
            //lblFixo.isHidden = !switchFixo.isOn
            //txtFixo.isHidden = !switchFixo.isOn
            //txtFixo.isEnabled = false
            txtCompany.isEnabled = false
            txtPaymentType.text = shift.paymentType
            txtShiftTime.text = shift.shiftTime == 1 ? "1 Hora" : "\(shift.shiftTime!) Horas"
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.locale = Locale(identifier: "pt_BR")
            txtSalary.text = nf.string(from: shift.salary! as NSNumber)
            colorIndicator.backgroundColor = UIColor(hexString: shift.company.color)
            if txtPaymentType.text! == "A Prazo" {
                constraintPaymentType.constant = 152
                txtPaymentDueDate.isHidden = false
                lblPaymentDueDate.isHidden = false
                formatter.dateFormat = "dd/MM/yyyy"
                txtPaymentDueDate.text = formatter.string(from: shift.paymentDueDate)
            } else if txtPaymentType.text!.hasPrefix("Após") {
                constraintPaymentType.constant = 126
                stepper.isHidden = false
            }
            
            if !shift.paid {
                btnPaid.isHidden = Calendar.current.date(byAdding: DateComponents(day: 1), to: shift.paymentDueDate)! < Date()
            }
        }
    }
    
    @IBAction func changeWeeks(_ sender: UIStepper) {
        var text = "Semana"
        
        if sender.value > 1 {
            text = "Semanas"
        }
        
        txtPaymentType.text = "Após \(Int(sender.value)) \(text)"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            
            amt = amt * 10 + digit
            
            if amt > 1_000_000_000_00 {
                
                let alert = UIAlertController(title: "Please enter amount less than 1 billion", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
                txtSalary.text = ""
                
                amt = 0
            }
            else {
                
                txtSalary.text = updateAmount()
            }
        }
        
        if string == "" {
            
            amt = amt/10
            
            txtSalary.text = amt == 0 ? "" : updateAmount()
        }
        
        return false
    }
    
    func updateAmount() -> String? {
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        
        formatter.numberStyle = NumberFormatter.Style.currency
        
        let amount = Double(amt/100) + Double(amt%100)/100
        
        return formatter.string(from: NSNumber(value: amount))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func scheduleNotification(_ shift: Shift) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Lembrete de Recebimento"
        content.body = "Seu plantão na empresa \(shift.company.name!) venceu há 1 dia"
        content.sound = UNNotificationSound.default()
        content.badge = content.badge == nil ? 1 : (Int(truncating: content.badge!) + 1) as NSNumber
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: Calendar.current.date(byAdding: DateComponents(day: 1), to: shift.paymentDueDate)!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: shift.id!, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }
}

