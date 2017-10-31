//
//  FirstSteps.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class FirstStepsController : UIViewController {
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var imgCheckProfile: UIImageView!
    @IBOutlet weak var txtProfile: UILabel!
    @IBOutlet weak var txtDescProfile: UILabel!
    @IBOutlet weak var imgCheckCompany: UIImageView!
    @IBOutlet weak var txtCompany: UILabel!
    @IBOutlet weak var txtDescCompany: UILabel!
    @IBOutlet weak var imgCheckShift: UIImageView!
    @IBOutlet weak var txtShift: UILabel!
    @IBOutlet weak var txtDescShift: UILabel!
    @IBOutlet weak var btnCompleteStep: UIRoundedButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = UserDefaults.standard.string(forKey: "name")?.split(separator: " ").first
        txtTitle.text = txtTitle.text!.replacingOccurrences(of: "%s", with: String(name!))
        
        if UserDefaults.standard.string(forKey: "profile") != nil {
            txtProfile.text = "Perfil Médico Cadastrado"
            txtProfile.textColor = UIColor(hexString: "#01aa01")
            
            if UserDefaults.standard.string(forKey: "companies") != nil {
                txtCompany.text = "Empresa Cadastrada"
                txtCompany.textColor = UIColor(hexString: "#01aa01")
                
                if UserDefaults.standard.string(forKey: "shifts") != nil {
                    txtShift.text = "Plantão Cadastrado"
                    txtShift.textColor = UIColor(hexString: "#01aa01")
                } else {
                    btnCompleteStep.setTitle("CADASTRAR PLANTÃO", for: .normal)
                }
            } else {
                btnCompleteStep.setTitle("CADASTRAR EMPRESA", for: .normal)
            }
        } else {
            btnCompleteStep.setTitle("CADASTRAR PERFIL", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.string(forKey: "profile") != nil {
            animate(label: txtProfile, img: imgCheckProfile)
            txtDescProfile.alpha = 0
            
            if UserDefaults.standard.string(forKey: "companies") != nil {
                animate(label: txtCompany, img: imgCheckCompany)
                txtDescCompany.alpha = 0
                
                if UserDefaults.standard.string(forKey: "shifts") != nil {
                    animate(label: txtShift, img: imgCheckShift)
                    txtDescShift.alpha = 0
                    
                    btnCompleteStep.isHidden = true
                    
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.performSegue(withIdentifier: "SegueFirstStepsToCompletion", sender: self)
                    }
                } else {
                    animate(label: txtShift, img: nil)
                    animate(label: txtDescShift, img: nil)
                }
            } else {
                animate(label: txtCompany, img: nil)
                animate(label: txtDescCompany, img: nil)
            }
        } else {
            animate(label: txtProfile, img: nil)
            animate(label: txtDescProfile, img: nil)
        }
    }
    
    @IBAction func completeStep() {
        if btnCompleteStep.titleLabel?.text == "CADASTRAR PERFIL" {
            self.performSegue(withIdentifier: "SegueFirstStepsToProfile", sender: self)
        } else if btnCompleteStep.titleLabel?.text == "CADASTRAR EMPRESA" {
            self.performSegue(withIdentifier: "SegueFirstStepsToCompany", sender: self)
        } else {
            self.performSegue(withIdentifier: "SegueFirstStepsToShifts", sender: self)
        }
    }
    
    private func animate(label: UILabel, img: UIImageView?) {
        UIView.animate(withDuration: 1.3) {
            self.btnCompleteStep.alpha = 1
            label.alpha = 1
            img?.alpha = 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueFirstStepsToProfile") {
            let vc = segue.destination as! ProfileController
            vc.sender = self
        } else if (segue.identifier == "SegueFirstStepsToCompany") {
            let vc = segue.destination as! CompanyController
            vc.sender = self
        } else if (segue.identifier == "SegueFirstStepsToShifts") {
            let vc = segue.destination as! ShiftController
            vc.sender = self
        }
    }
}
