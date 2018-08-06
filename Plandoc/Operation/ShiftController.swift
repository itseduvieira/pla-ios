//
//  ShiftController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import UserNotifications
import PromiseKit

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
    @IBOutlet weak var constraintHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintTxtCompany: NSLayoutConstraint!
    
    weak var sender: UIViewController!
    var id: String!
    var dateFilled: Date!
    
    var ignoreAlert = false
    
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
    
    let fixoTitle = ["Semanal", "Quinzenal"]
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
        
        if UIScreen.main.bounds.height < 500 {
            self.adjust4s()
        }
    }
    
    private func adjust4s() {
        imgPicture.isHidden = true
        constraintHeader.constant = 78
        constraintTxtCompany.constant = 94
    }
    
    @IBAction func changeFixo(_ sender: UISwitch) {
        if sender.isOn {
            txtFixo.isHidden = false
            lblFixo.isHidden = false
            txtFixo.becomeFirstResponder()
            
            txtFixo.text = "por 1 Mês"
            
            if txtPaymentType.text == "A Prazo" {
                txtPaymentType.text = ""
            }
            
            paymentTypeData.removeLast()
        } else {
            txtFixo.isHidden = true
            lblFixo.isHidden = true
            txtFixo.resignFirstResponder()
            
            paymentTypeData.append("A Prazo")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dictCompanies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] ?? [:]
        
        self.companiesData = [Data](dictCompanies.values)
        
        if companiesData.isEmpty && self.id == nil && !ignoreAlert {
            let alertController = UIAlertController(title: "Nenhuma Empresa Cadastrada", message: "Para cadastrar um plantão, primeiro você deve cadastrar uma empresa.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Entendi", style: .cancel, handler: {action in
                self.performSegue(withIdentifier: "SegueShiftsToCompany", sender: self)
            })
            alertController.addAction(defaultAction)
            
            let dismissAction = UIAlertAction(title: "Agora Não", style: .destructive, handler: { action in
                self.cancel()
            })
            alertController.addAction(dismissAction)
            
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
        let alert = UIAlertController(title: "Mais Opções", message: "O que você deseja fazer?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Salvar Alterações", style: .default, handler: { action in
            self.save()
        }))
        alert.addAction(UIAlertAction(title: "Marcar Como Recebido", style: .default, handler: { action in
            self.pay()
        }))
        alert.addAction(UIAlertAction(title: "Remover Plantão", style: .destructive, handler: { action in
            self.delete()
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
            self.presentAlert()
            
            var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
            
            var pdcShift = Shift()
            var isNew = false
            
            if let id = self.id {
                pdcShift = NSKeyedUnarchiver.unarchiveObject(with: shifts[id]!) as! Shift
            } else {
                isNew = true
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            let date = formatter.date(from: "\(self.txtDate.text!) \(self.txtHour.text!)")!
            
            pdcShift.salary = Double(txtSalary.text!.replacingOccurrences(of: "R$", with: "").replacingOccurrences(of: ".", with: "") .replacingOccurrences(of: ",", with: "."))
            pdcShift.date = date
            pdcShift.paymentType = txtPaymentType.text!
            pdcShift.shiftTime = Int(txtShiftTime.text!.components(separatedBy: " ")[0])
            pdcShift.companyId = companyChoosed
            pdcShift.paid = false
            
            let dictCompanies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] ?? [:]
            let company = NSKeyedUnarchiver.unarchiveObject(with: dictCompanies[pdcShift.companyId]!) as! Company
            pdcShift.company = company
            
            if isNew {
                if switchFixo.isOn && !txtFixo.isHidden {
                    let groupId = String.random()
                    pdcShift.groupId = groupId
                    
                    createShiftGroup(pdcShift)
                } else {
                    pdcShift.id = String.random()
                    pdcShift.paymentDueDate = calcDueDate(pdcShift)
                    
                    createSingleShift(pdcShift)
                }
            } else {
                pdcShift.paymentDueDate = calcDueDate(pdcShift)
                
                updateShift(pdcShift)
            }
        }
    }
    
    private func calcDueDate(_ pdcShift: Shift) -> Date {
        if pdcShift.paymentType == "Final do Mês Atual" {
            let interval = Calendar.current.dateInterval(of: .month, for: pdcShift.date)
            return Calendar.current.date(byAdding: DateComponents(day: -1), to: interval!.end)!
        } else if pdcShift.paymentType == "Final do Próximo Mês" {
            let interval = Calendar.current.dateInterval(of: .month, for: Calendar.current.date(byAdding: DateComponents(month: 1), to: pdcShift.date)!)
            return Calendar.current.date(byAdding: DateComponents(day: -1), to: interval!.end)!
        } else if pdcShift.paymentType.hasPrefix("Após") {
            let weeks = Int(pdcShift.paymentType.components(separatedBy: " ")[1])!
            return Calendar.current.date(byAdding: DateComponents(day: 7 * weeks), to: pdcShift.date)!
        } else if pdcShift.paymentType == "A Prazo" {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.date(from: txtPaymentDueDate.text!)!
        } else {
            return pdcShift.date
        }
    }
    
    private func createSingleShift(_ pdcShift: Shift) {
        firstly {
            DataAccess.instance.createShift(pdcShift)
        }.done {
            self.saveLocalAndExit(pdcShift)
        }.catch { error in
            self.dismissCustomAlert()
            
            self.showNetworkError(msg: "Não foi possível enviar os dados do Plantão. Verifique sua conexão com a Internet e tente novamente.", {
                self.presentAlert()
                
                self.createSingleShift(pdcShift)
            })
        }
    }
    
    private func updateShift(_ pdcShift: Shift) {
        firstly {
            DataAccess.instance.updateShift(pdcShift)
        }.done {
            self.saveLocalAndExit(pdcShift)
        }.catch { error in
            self.dismissCustomAlert()
            
            self.showNetworkError(msg: "Não foi possível enviar os dados do Plantão. Verifique sua conexão com a Internet e tente novamente.", {
                self.presentAlert()
                
                self.updateShift(pdcShift)
            })
        }
    }
    
    private func saveLocalAndExit(_ pdcShift: Shift) {
        var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
        
        let shift = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
        
        shifts[pdcShift.id] = shift
        
        UserDefaults.standard.set(shifts, forKey: "shifts")
        
        self.cancel()
    }
    
    private func createShiftGroup(_ model: Shift) {
        var shiftsToSave: [Shift] = []
        
        let weeks = Int(txtFixo.text!.split(separator: " ")[1])! * 4
        let initialDate = model.date
        
        for index in 0...weeks {
            let pdcShift = Shift()
            pdcShift.id = String.random()
            pdcShift.groupId = model.groupId
            pdcShift.companyId = model.companyId
            pdcShift.company = model.company
            pdcShift.shiftTime = model.shiftTime
            pdcShift.paymentType = model.paymentType
            pdcShift.paymentDueDate = model.paymentDueDate
            pdcShift.salary = model.salary
            pdcShift.paid = model.paid
            
            if index > 0 {
                if lblFixo.text! == "Quinzenalmente" && index % 2 != 0 {
                    continue
                }
                
                pdcShift.date = Calendar.current.date(byAdding: DateComponents(day: 7 * index), to: initialDate!)
                pdcShift.paymentDueDate = calcDueDate(pdcShift)
            } else {
                pdcShift.date = initialDate
                pdcShift.paymentDueDate = calcDueDate(pdcShift)
            }
            
            shiftsToSave.append(pdcShift)
        }
        
        when(fulfilled: shiftsToSave.map({ shift -> Promise<Void> in
            return Promise<Void> { seal in
                firstly {
                    DataAccess.instance.createShift(shift)
                }.done {
                    seal.fulfill(())
                }.catch { error in
                    seal.reject(error)
                }
            }
        })).done {
            var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
            
            for s in shiftsToSave {
                let shift = NSKeyedArchiver.archivedData(withRootObject: s)
                shifts[s.id] = shift
            }
            
            UserDefaults.standard.set(shifts, forKey: "shifts")
            
            self.cancel()
        }.catch(policy: .allErrors) { error in
            self.handleErrorGroup(model)
        }
    }
    
    private func handleErrorGroup(_ pdcShift: Shift) {
        self.dismissCustomAlert()
        
        self.showNetworkError(msg: "Não foi possível enviar os dados do Plantão. Verifique sua conexão com a Internet e tente novamente.", {
            self.presentAlert()
            
            firstly {
                DataAccess.instance.deleteShiftGroup(pdcShift.groupId)
            }.done {
                self.createShiftGroup(pdcShift)
            }.catch { error in
                self.handleErrorGroup(pdcShift)
            }
        })
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
        self.presentAlert()
        
        var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
        let pdcShift = NSKeyedUnarchiver.unarchiveObject(with: shifts[self.id]!) as! Shift
        pdcShift.paid = true
        
        firstly {
            DataAccess.instance.updateShift(pdcShift)
        }.done {
            let shift = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
            shifts[pdcShift.id] = shift
            UserDefaults.standard.set(shifts, forKey: "shifts")
            
            let center = UNUserNotificationCenter.current()
            center.removeDeliveredNotifications(withIdentifiers: [self.id])
            center.removePendingNotificationRequests(withIdentifiers: [self.id])
            
            self.cancel()
        }.catch { error in
            self.dismissCustomAlert()
            
            self.showNetworkError(msg: "Não foi possível enviar os dados do Plantão. Verifique sua conexão com a Internet e tente novamente.", {
                self.pay()
            })
        }
    }
    
    private func delete() {
        self.presentAlert()
        
        firstly {
            DataAccess.instance.deleteShift(self.id)
        }.done {
            var dict = UserDefaults.standard.dictionary(forKey: "shifts") as! [String:Data]
            dict.removeValue(forKey: self.id)
            
            UserDefaults.standard.set(dict, forKey: "shifts")
            
            self.cancel()
        }.catch { error in
            self.dismissCustomAlert()
            
            self.showNetworkError(msg: "Não foi possível apagar o Plantão. Verifique sua conexão com a Internet e tente novamente.", {
                self.delete()
            })
        }
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
                done = "Mais..."
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
        if txtFixo.isFirstResponder {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if txtFixo.isFirstResponder {
            if component == 0 {
                return fixoTitle.count
            } else {
                return fixoData.count
            }
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
            if component == 0 {
                return (fixoTitle[row])
            } else {
                return (fixoData[row])
            }
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
            if component == 0 {
                lblFixo.text = row == 0 ? "Semanalmente" : "Quinzenalmente"
            } else {
                txtFixo.text = "por \(fixoData[row])"
            }
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
            self.companyChoosed = shift.company.id
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
        } else if let date = self.dateFilled {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            txtDate.text = formatter.string(from: date)
            formatter.dateFormat = "HH:mm"
            txtHour.text = formatter.string(from: Date())
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

