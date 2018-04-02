//
//  ExpenseDetailController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 28/02/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class ExpenseDetailController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtDesc: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtValue: UITextField!
    @IBOutlet weak var lblFixo: UILabel!
    @IBOutlet weak var txtFixo: UITextField!
    @IBOutlet weak var switchFixo: UISwitch!
    @IBOutlet weak var constraintHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintTxtTitle: NSLayoutConstraint!
    
    var id: String!
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    var fixoData: [String] = {
        var data: [String] = []
        data.append("1 Mês")
        for index in 2...36 {
            data.append("\(index) Meses")
        }
        return data
    }()
    
    var amt: Int = 0
    var picker: UIPickerView!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.setNavigationBar()
        
        self.applyBorders()
        
        UITextField.connectFields(fields: [txtDesc, txtDate, txtValue])
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        datePicker.locale = Locale(identifier: "pt_BR")
        txtDate.inputView = datePicker
        
        txtValue.delegate = self
        txtValue.placeholder = updateAmount()
        
        self.setupDateField()
        
        self.loadExistingData()
    
        if UIScreen.main.bounds.height < 500 {
            self.adjust4s()
        }
    }
    
    private func adjust4s() {
        imgPicture.isHidden = true
        constraintHeader.constant = 64
        constraintTxtTitle.constant = 70
    }
    
    private func loadExistingData() {
        if let id = self.id {
            var expenses = UserDefaults.standard.dictionary(forKey: "expenses") as? [String:Data] ?? [:]
            let expense = NSKeyedUnarchiver.unarchiveObject(with: expenses[id]!) as! Expense
            txtDesc.text = expense.title
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            txtDate.text = formatter.string(from: expense.date)
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.locale = Locale(identifier: "pt_BR")
            txtValue.text = nf.string(from: expense.value as NSNumber)
            switchFixo.isOn = expense.groupId != nil
        }
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        txtDate.text = formatter.string(from: sender.date)
    }
    
    @objc func doneDate() {
        if txtDate.isFirstResponder {
            txtValue.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            
            amt = amt * 10 + digit
            
            if amt > 1_000_000_000_00 {
                
                let alert = UIAlertController(title: "Please enter amount less than 1 billion", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
                txtValue.text = ""
                
                amt = 0
            }
            else {
                
                txtValue.text = updateAmount()
            }
        }
        
        if string == "" {
            
            amt = amt/10
            
            txtValue.text = amt == 0 ? "" : updateAmount()
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
    
    private func setupPictureRound() {
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
    }
    
    private func applyBorders() {
        txtDesc.applyBottomBorder()
        txtDate.applyBottomBorder()
        txtValue.applyBottomBorder()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(cancel))
        navItem.leftBarButtonItem = backItem
        let doneItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(save))
        navItem.rightBarButtonItem = doneItem
    }
    
    @IBAction func changeFixo(_ sender: UISwitch) {
        if sender.isOn {
            txtFixo.isHidden = false
            lblFixo.isHidden = false
            txtFixo.becomeFirstResponder()
        } else {
            txtFixo.isHidden = true
            lblFixo.isHidden = true
            txtFixo.resignFirstResponder()
        }
    }
    
    @objc func save() {
        if txtDesc.text! == "" || txtDate.text! == "" || txtValue.text! == "" {
            let alertController = UIAlertController(title: "Erro", message: "Preencha corretamente os campos.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let date = formatter.date(from: self.txtDate.text!)!
            
            if switchFixo.isOn && !txtFixo.isHidden {
                let months = Int(txtFixo.text!.split(separator: " ")[1])!
                let groupId = String.random()
                for index in 0..<months {
                    if index == 0 {
                        saveOne(groupId, date: date)
                    } else {
                        saveOne(groupId, date: Calendar.current.date(byAdding: DateComponents(month: index), to: date)!)
                    }
                }
            } else {
                saveOne(nil, date: date)
            }
            
            cancel()
        }
    }
    
    private func saveOne(_ groupId: String?, date: Date) {
        
            var expenses = UserDefaults.standard.dictionary(forKey: "expenses") as? [String:Data] ?? [:]
            
            var pdcExpense = Expense()
            
            if let id = self.id {
                pdcExpense = NSKeyedUnarchiver.unarchiveObject(with: expenses[id]!) as! Expense
            } else {
                pdcExpense.id = String.random()
                pdcExpense.groupId = groupId
            }
            
            pdcExpense.title = txtDesc.text
            pdcExpense.date = date
        
            pdcExpense.value = Double(txtValue.text!.replacingOccurrences(of: "R$", with: "").replacingOccurrences(of: ".", with: "") .replacingOccurrences(of: ",", with: "."))
            
            let expense = NSKeyedArchiver.archivedData(withRootObject: pdcExpense)
            
            expenses[pdcExpense.id] = expense
            
            UserDefaults.standard.set(expenses, forKey: "expenses")
    }
    
    @objc func cancel() {
        self.performSegue(withIdentifier: "SegueUnwindToExpenses", sender: self)
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
        }
        
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if txtFixo.isFirstResponder {
            return (fixoData[row])
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if txtFixo.isFirstResponder {
            return txtFixo.text = "por \(fixoData[row])"
        }
    }
    
    @objc func doneClick() {
        if txtFixo.isFirstResponder {
            txtFixo.resignFirstResponder()
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
}
