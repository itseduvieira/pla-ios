//
//  ProfileController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class ProfileController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    //MARK: Properties
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtCRM: UITextField!
    @IBOutlet weak var txtUF: UITextField!
    @IBOutlet weak var txtGraduationDate: UITextField!
    @IBOutlet weak var txtGraduation: UITextField!
    @IBOutlet weak var txtField: UITextField!
    
    let imagePicker = UIImagePickerController()
    var fieldPicker: UIPickerView!
    
    weak var sender: UIViewController!
    
    let pickerFieldData = [
        "", "Acupuntura", "Alergia e Imunologia", "Anestesiologia", "Angiologia", "Cancerologia", "Cardiologia", "Cirurgia Cardiovascular", "Cirurgia da Mão", "Cirurgia de Cabeça e Pescoço", "Cirurgia do Aparelho Digestivo", "Cirurgia Geral", "Cirurgia Pediátrica",
        "Cirurgia Plástica", "Cirurgia Torácica", "Cirurgia Vascular", "Clínica Médica", "Coloproctologia", "Dermatologia", "Endocrinologia", "Endoscopia", "Gastroenterologia", "Genética Médica", "Geriatria", "Ginecologia e Obstetrícia",
        "Hematologia e Hemoterapia", "Homeopatia", "Infectologia", "Mastologia", "Medicina de Família e Comunidade", "Medicina do Trabalho", "Medicina de Tráfego", "Medicina Esportiva", "Medicina Física e Reabilitação", "Medicina Intensiva", "Medicina Legal", "Medicina Nuclear",
        "Medicina Preventiva e Social", "Nefrologia", "Neurocirurgia", "Neurologia", "Nutrologia", "Oftalmologia", "Ortopedia e Traumatologia", "Otorrinolaringologia", "Patologia", "Patologia Clínica/Medicina Laboratorial", "Pediatria", "Pneumologia",
        "Psiquiatria", "Radiologia e Diagnóstico por Imagem", "Radioterapia", "Reumatologia", "Urologia"
    ]
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        self.setupPictureRound()
        
        self.applyBorders()
        
        self.hideKeyboardWhenTappedAround()
        
        self.setupCRMField()
        
        self.setupGraduationDateField()
        
        //UITextField.connectFields(fields: [txtCRM, txtUF, txtGraduationDate, txtGraduation, txtField])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        txtCRM.becomeFirstResponder()
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
    
    @IBAction func chooseField() {
        self.pickUp(txtField)
    }
    
    @IBAction func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueProfileToFirstSteps", sender: self)
        }
    }
    
    @IBAction func openPicker(_ sender: UITextField) {
        let datePickerView = MonthYearPickerView()
        
        //datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        
//        datePickerView.addTarget(self, action: #selector(ProfileController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        datePickerView.onDateSelected = { (month: Int, year: Int) in
            self.txtGraduationDate.text = DateFormatter().monthSymbols[month - 1].capitalized + " de " + String(year)
        }
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerFieldData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerFieldData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtField.text = pickerFieldData[row]
    }
    
    @objc func doneClick() {
        txtField.resignFirstResponder()
    }
    
    func pickUp(_ textField : UITextField){
        self.fieldPicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.fieldPicker.delegate = self
        self.fieldPicker.dataSource = self
        textField.inputView = self.fieldPicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(ProfileController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneToolbarGraduation() {
        txtGraduationDate.resignFirstResponder()
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
        txtCRM.resignFirstResponder()
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
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
        imgProfile.clipsToBounds = true
        
//        imgProfile.layer.borderWidth = 2.0;
//        imgProfile.layer.borderColor = UIColor(hexString: "#1D9DD5").cgColor
    }
}
