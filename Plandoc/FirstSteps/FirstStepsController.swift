//
//  FirstSteps.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import UserNotifications
import PromiseKit

class FirstStepsController : UIViewController, UNUserNotificationCenterDelegate {
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
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.delegate = self
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {                     completionHandler(.alert)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let data = UserDefaults.standard.object(forKey: "activation") as? NSData,
            let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? Plandoc.User {
            let name = pdcUser.name.split(separator: " ").first
            txtTitle.text = txtTitle.text!.replacingOccurrences(of: "%s", with: String(name!))
        }
        
        if UserDefaults.standard.object(forKey: "profile") != nil {
            txtProfile.text = "Perfil Médico Cadastrado"
            txtProfile.textColor = UIColor(hexString: "#01aa01")
            
            if UserDefaults.standard.object(forKey: "companies") != nil {
                txtCompany.text = "Empresa Cadastrada"
                txtCompany.textColor = UIColor(hexString: "#01aa01")
                
                if UserDefaults.standard.object(forKey: "shifts") != nil {
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
        
        if UserDefaults.standard.object(forKey: "profile") != nil {
            animate(label: txtProfile, img: imgCheckProfile)
            animate(label: txtDescProfile, img: nil)
            
            if UserDefaults.standard.object(forKey: "companies") != nil {
                animate(label: txtCompany, img: imgCheckCompany)
                animate(label: txtDescCompany, img: nil)
                
                if UserDefaults.standard.object(forKey: "shifts") != nil {
                    animate(label: txtShift, img: imgCheckShift)
                    animate(label: txtDescShift, img: nil)
                    
                    btnCompleteStep.isHidden = true
                    
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        firstly {
                            DataAccess.instance.createPreferences()
                        }.then {
                            DataAccess.instance.setPreference("online", true)
                        }.done {
                            UserDefaults.standard.set(true, forKey: "online")
                            self.performSegue(withIdentifier: "SegueFirstStepsToCompletion", sender: self)
                        }.catch { error in
                            print(error)
                        }
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
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let skipItem = UIBarButtonItem(title: "Pular", style: .plain, target: self, action: #selector(skip))
        navItem.rightBarButtonItem = skipItem
    }
    
    @objc func skip() {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: Profile()), forKey: "profile")
        UserDefaults.standard.set([String:Data](), forKey: "companies")
        UserDefaults.standard.set([String:Data](), forKey: "shifts")
        self.viewWillAppear(true)
        self.viewDidAppear(true)
    }
}
