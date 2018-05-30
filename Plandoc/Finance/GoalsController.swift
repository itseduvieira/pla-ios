//
//  GoalsController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/02/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class GoalsController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtValue: UITextField!
    @IBOutlet weak var constraintHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintTxtValue: NSLayoutConstraint!
    @IBOutlet weak var switchAtivo: UISwitch!
    
    var amt: Int = 0
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        self.setupPictureRound()
        
        self.applyBorders()
        
        self.hideKeyboardWhenTappedAround()
        
        txtValue.delegate = self
        txtValue.placeholder = updateAmount()
        
        self.loadExistingData()
    
        if UIScreen.main.bounds.height < 500 {
            self.adjust4s()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.bool(forKey: "goalTutorial") {
            self.presentLargeAlert(self, {
                UserDefaults.standard.set(true, forKey: "goalTutorial")
            })
        }
    }
    
    @IBAction func openTutorial() {        
        self.presentLargeAlert(self, {
            UserDefaults.standard.set(true, forKey: "goalTutorial")
        })
    }
    
    private func adjust4s() {
        imgPicture.isHidden = true
        constraintHeader.constant = 64
        constraintTxtValue.constant = 70
    }
    
    private func loadExistingData() {
        switchAtivo.isOn = UserDefaults.standard.bool(forKey: "goalActive")
        
        if let value = UserDefaults.standard.object(forKey: "goalValue") {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.locale = Locale(identifier: "pt_BR")
            txtValue.text = nf.string(from: value as! NSNumber)
            
            
        }
    }
    
    private func applyBorders() {
        txtValue.applyBottomBorder()
    }
    
    private func setupPictureRound() {
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        let saveItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(save))
        navItem.leftBarButtonItem = backItem
        navItem.rightBarButtonItem = saveItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueUnwindToExtendedMenu", sender: self)
    }
    
    @objc func save() {
        if switchAtivo.isOn && txtValue.text! == "" {
            let alertController = UIAlertController(title: "Erro", message: "Preencha corretamente os campos.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            UserDefaults.standard.set(switchAtivo.isOn, forKey: "goalActive")
            DataAccess.instance.setPreference("goalActive", switchAtivo.isOn)
            
            var value: Double = 0.0
            
            if txtValue.text! != "" {
                value = Double(txtValue.text!.replacingOccurrences(of: "R$", with: "").replacingOccurrences(of: ".", with: "") .replacingOccurrences(of: ",", with: "."))!
            }
            
            UserDefaults.standard.set(value, forKey: "goalValue")
            DataAccess.instance.setPreference("goalValue", value)
            
            let alertController = UIAlertController(title: "Meta Financeira", message: "A Meta Financeira foi salva com sucesso.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func updateAmount() -> String? {
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        
        formatter.numberStyle = NumberFormatter.Style.currency
        
        let amount = Double(amt/100) + Double(amt%100)/100
        
        return formatter.string(from: NSNumber(value: amount))
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
}
