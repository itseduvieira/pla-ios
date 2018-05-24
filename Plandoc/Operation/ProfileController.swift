//
//  ProfileController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class ProfileController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    //MARK: Properties
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtCRM: UITextField!
    @IBOutlet weak var txtUF: UITextField!
    @IBOutlet weak var txtGraduationDate: UITextField!
    @IBOutlet weak var txtGraduation: UITextField!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var constraintHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintTxtCRM: NSLayoutConstraint!
    @IBOutlet weak var constraintTxtUF: NSLayoutConstraint!
    
    var picker: UIPickerView!
    
    weak var sender: UIViewController!
    
    let pickerFieldData = [
        "Acupuntura", "Alergia e Imunologia", "Anestesiologia", "Angiologia", "Cancerologia", "Cardiologia", "Cirurgia Cardiovascular", "Cirurgia da Mão", "Cirurgia de Cabeça e Pescoço", "Cirurgia do Aparelho Digestivo", "Cirurgia Geral", "Cirurgia Pediátrica",
        "Cirurgia Plástica", "Cirurgia Torácica", "Cirurgia Vascular", "Clínica Médica", "Coloproctologia", "Dermatologia", "Endocrinologia", "Endoscopia", "Gastroenterologia", "Genética Médica", "Geriatria", "Ginecologia e Obstetrícia",
        "Hematologia e Hemoterapia", "Homeopatia", "Infectologia", "Mastologia", "Medicina de Família e Comunidade", "Medicina do Trabalho", "Medicina de Tráfego", "Medicina Esportiva", "Medicina Física e Reabilitação", "Medicina Intensiva", "Medicina Legal", "Medicina Nuclear",
        "Medicina Preventiva e Social", "Nefrologia", "Neurocirurgia", "Neurologia", "Nutrologia", "Oftalmologia", "Ortopedia e Traumatologia", "Otorrinolaringologia", "Patologia", "Patologia Clínica/Medicina Laboratorial", "Pediatria", "Pneumologia",
        "Psiquiatria", "Radiologia e Diagnóstico por Imagem", "Radioterapia", "Reumatologia", "Urologia", "Outra"
    ]
    
    let pickerUFData = [
        "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO",
        "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI",
        "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"
    ]
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.applyBorders()
        
        self.hideKeyboardWhenTappedAround()
        
        self.setupCRMField()
        
        self.setupGraduationDateField()
        
        self.setNavigationBar()
        
        self.loadExistingData()
        
        UITextField.connectFields(fields: [txtCRM, txtUF, txtGraduationDate, txtGraduation, txtField])
    
        if UIScreen.main.bounds.height < 500 {
            self.adjust4s()
        }
    }
    
    private func adjust4s() {
        imgPicture.isHidden = true
        constraintHeader.constant = 64
        constraintTxtCRM.constant = 70
        constraintTxtUF.constant = 70
    }
    
    @objc func save() {
        if txtCRM.text! == "" || txtUF.text! == "" || txtGraduationDate.text! == "" || txtField.text! == "" || txtGraduation.text! == "" {
            let alertController = UIAlertController(title: "Erro", message: "Preencha corretamente os campos.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let pdcProfile = Profile()
            pdcProfile.crm = txtCRM.text
            pdcProfile.uf = txtUF.text
            pdcProfile.graduationDate = txtGraduationDate.text
            pdcProfile.field = txtField.text
            pdcProfile.institution = txtGraduation.text
            
            let profile = NSKeyedArchiver.archivedData(withRootObject: pdcProfile)
            UserDefaults.standard.set(profile, forKey: "profile")
            
            DataAccess.updateProfile(pdcProfile)
            
            cancel()
        }
    }

    @IBAction func chooseUF() {
        self.pickUp(txtUF)
    }
    
    @IBAction func chooseField() {
        self.pickUp(txtField)
    }
    
    @objc func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueProfileToFirstSteps", sender: self)
        } else {
            if self.sender.restorationIdentifier == "AccountViewController" {
                self.performSegue(withIdentifier: "SegueUnwindToAccount", sender: self)
            }
        }
    }
    
    @IBAction func openPicker(_ sender: UITextField) {
        let datePickerView = MonthYearPickerView()
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.dateFormat = "MMMM 'de' yyyy"
        
        sender.inputView = datePickerView
        
        if (txtGraduationDate.text?.isEmpty)! {
            txtGraduationDate.text = df.string(from: Date())
        }
        
        datePickerView.onDateSelected = { (month: Int, year: Int) in
            self.txtGraduationDate.text = "\(df.monthSymbols[month - 1]) de \(String(year))"
        }
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.dateFormat = "MMMM 'de' yyyy"
        
        txtGraduationDate.text = df.string(for: sender.date)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if txtField.isFirstResponder {
            return pickerFieldData.count
        } else if txtUF.isFirstResponder {
            return pickerUFData.count
        }
        
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if txtField.isFirstResponder {
            return pickerFieldData[row]
        } else if txtUF.isFirstResponder {
            return pickerUFData[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if txtField.isFirstResponder {
            txtField.text = pickerFieldData[row]
        } else if txtUF.isFirstResponder {
            txtUF.text = pickerUFData[row]
        }
    }
    
    @objc func doneClick() {
        if txtField.isFirstResponder {
            txtField.resignFirstResponder()
        } else if txtUF.isFirstResponder {
            txtGraduationDate.becomeFirstResponder()
        }
    }
    
    func pickUp(_ textField : UITextField){
        self.picker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.picker.delegate = self
        self.picker.dataSource = self
        
        textField.inputView = self.picker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(ProfileController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        if txtField.text!.isEmpty {
            self.picker.delegate?.pickerView!(self.picker, didSelectRow: 0, inComponent: 0)
        } else if txtUF.text!.isEmpty {
            self.picker.delegate?.pickerView!(self.picker, didSelectRow: 0, inComponent: 0)
        }
    }
    
    @objc func doneToolbarGraduation() {
        txtGraduation.becomeFirstResponder()
    }
    
    private func setupGraduationDateField() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(ProfileController.doneToolbarGraduation))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtGraduationDate.inputAccessoryView = toolBar
    }
    
    @objc func doneToolbarCRM() {
        txtUF.becomeFirstResponder()
    }
    
    private func setupCRMField() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Pronto", style: .done, target: self, action: #selector(ProfileController.doneToolbarCRM))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtCRM.inputAccessoryView = toolBar
    }
    
    private func applyBorders() {
        txtCRM.applyBottomBorder()
        txtUF.applyBottomBorder()
        txtGraduationDate.applyBottomBorder()
        txtGraduation.applyBottomBorder()
        txtField.applyBottomBorder()
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
    
    private func loadExistingData() {
        guard let profile = UserDefaults.standard.object(forKey: "profile") else {
            return
        }
        
        let pdcProfile = NSKeyedUnarchiver.unarchiveObject(with: profile as! Data) as! Profile
        txtCRM.text = pdcProfile.crm
        txtUF.text = pdcProfile.uf
        txtGraduationDate.text = pdcProfile.graduationDate
        txtGraduation.text = pdcProfile.institution
        txtField.text = pdcProfile.field
    }
}
