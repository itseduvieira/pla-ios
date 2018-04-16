//
//  PreferencesController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 13/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import FacebookCore
import FBSDKCoreKit

class PreferencesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var imgFacebook: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var path: URL!
    
    @IBAction func unwindToPrefs(segue: UIStoryboardSegue) {}
    
    enum TableSection: Int {
        case security = 0, notifications, social, general, end, total
    }

    let SectionHeaderHeight: CGFloat = 55
    
    var data = [
        TableSection.security: [
            "Acesso via Biometria"
        ],
        TableSection.notifications: [
            "Lembrar Vencimentos",
            "Lembrar Plantões"
        ],
        TableSection.social: [
            "Indique a um Amigo",
            "Vincular Facebook"
        ],
        TableSection.general: [
            "Privacidade e Termos de Uso",
            "Apagar Dados"
        ],
        TableSection.end: [
            "Sair"
        ]
    ]
    
    //MARK: Action
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueUnwindToExtendedMenu", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableSection = TableSection(rawValue: section), let titles = data[tableSection] {
            return titles.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection = TableSection(rawValue: section), let movieData = data[tableSection], movieData.count > 0 {
            return SectionHeaderHeight
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        
        view.backgroundColor = UIColor(hexString: "#EBEBF1")
        view.layer.addBorder(edge: .top, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        view.layer.addBorder(edge: .bottom, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        
        let label = UILabel(frame: CGRect(x: 15, y: SectionHeaderHeight - 24, width: tableView.bounds.width - 30, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hexString: "#78000000")
        
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .security:
                label.text = "SEGURANÇA"
            case .notifications:
                label.text = "NOTIFICAÇÕES"
            case .social:
                label.text = "SOCIAL"
            case .general:
                label.text = "GERAL"
            case .end:
                label.text = ""
            default:
                label.text = ""
            }
        }
        view.addSubview(label)
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let tableSection = TableSection(rawValue: indexPath.section), let title = data[tableSection]?[indexPath.row] {
            
            if let titleLabel = cell.viewWithTag(10) as? UILabel {
                titleLabel.text = title
            }
            
            if indexPath.section == TableSection.social.rawValue && indexPath.row == 1 {
                    for info in Auth.auth().currentUser!.providerData {
                        if info.providerID == "facebook.com" {
                            (cell.viewWithTag(10) as! UILabel).text = "Vinculado ao Facebook"
                            break
                        }
                    }
            }
            
            switch indexPath.section {
                case TableSection.security.rawValue:
                    switch indexPath.row {
                    case 0:
                        if let switchMenu = cell.viewWithTag(20) as? UISwitch {
                            switchMenu.isHidden = false
                            switchMenu.isOn = UserDefaults.standard.bool(forKey: "biometrics")
                            switchMenu.addTarget(self, action: #selector(biometricsChanged), for: .valueChanged)
                        }
                        
                        break
                    default:
                        print("Row \(indexPath.row)")
                    }
            case TableSection.notifications.rawValue:
                switch indexPath.row {
                case 0:
                    if let switchMenu = cell.viewWithTag(20) as? UISwitch {
                        switchMenu.isHidden = false
                        switchMenu.isOn = UserDefaults.standard.bool(forKey: "notificationIncome")
                        switchMenu.addTarget(self, action: #selector(notificationIncomeChanged), for: .valueChanged)
                    }
                    
                    break
                case 1:
                    if let switchMenu = cell.viewWithTag(20) as? UISwitch {
                        switchMenu.isHidden = false
                        switchMenu.isOn = UserDefaults.standard.bool(forKey: "notificationShifts")
                        switchMenu.addTarget(self, action: #selector(notificationShiftsChanged), for: .valueChanged)
                    }
                    
                    break
                default:
                    print("Row \(indexPath.row)")
                }
            default:
                if let switchMenu = cell.viewWithTag(20) as? UISwitch {
                    switchMenu.isHidden = true
                }
                
                print("Row \(indexPath.section)")
            }
        }
        
        return cell
    }
    
    @objc func biometricsChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "biometrics")
        
        if sender.isOn {
            print("on")
        } else {
            print("off")
        }
    }
    
    @objc func notificationIncomeChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "notificationIncome")
        
        if sender.isOn {
            print("on")
        } else {
            print("off")
        }
    }
    
    @objc func notificationShiftsChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "notificationShifts")
        
        if sender.isOn {
            print("on")
        } else {
            print("off")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case TableSection.security.rawValue:
            switch indexPath.row {
            case 0:
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                print("Row \(indexPath.row)")
            }
        case TableSection.notifications.rawValue:
            switch indexPath.row {
            case 0:
                tableView.deselectRow(at: indexPath, animated: true)
            case 1:
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                print("Row \(indexPath.row)")
            }
        case TableSection.social.rawValue:
            switch indexPath.row {
            case 0:
                let textToShare = "Doutor, tenha o controle de suas finanças na palma da mão. Confira mais no site "
                
                if let myWebsite = NSURL(string: "http://www.plandoc.com.br") {
                    let objectsToShare = [textToShare, myWebsite] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    
                    activityVC.popoverPresentationController?.sourceView = tableView
                    self.present(activityVC, animated: true, completion: {
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                }
                
                break
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                checkFacebook(indexPath, (cell.viewWithTag(10) as! UILabel))
                
                break
            default:
                print("Row \(indexPath.row)")
            }
        case TableSection.general.rawValue:
            switch indexPath.row {
            case 0:
                showTerms(indexPath)
                
                break
            case 1:
                eraseData(indexPath)
                
                break
            default:
                print("Row \(indexPath.row)")
            }
            
            break
        case TableSection.end.rawValue:
            switch indexPath.row {
            case 0:
                logoff()
                
                break
            default:
                print("Row \(indexPath.row)")
            }
        default:
            print("Section \(indexPath.row)")
        }
    }
    
    func logoff() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error at signOut")
        }
        
        UserDefaults.standard.removeObject(forKey: "loggedUser")
        self.performSegue(withIdentifier: "SeguePreferencesToLogin", sender: self)
    }
    
    func eraseData(_ index: IndexPath) {
        let alert = UIAlertController(title: "Remover Dados do Aplicativo", message: "Esta ação irá remover TODOS os dados do aplicativo. Deseja continuar?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sim, remover os dados", style: .destructive, handler: { action in
            UserDefaults.standard.removeObject(forKey: "shifts")
            UserDefaults.standard.removeObject(forKey: "companies")
            UserDefaults.standard.removeObject(forKey: "profile")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")
            UserDefaults.standard.removeObject(forKey: "goalActive")
            UserDefaults.standard.removeObject(forKey: "goalValue")
            UserDefaults.standard.removeObject(forKey: "notificationIncome")
            UserDefaults.standard.removeObject(forKey: "notificationShifts")
            UserDefaults.standard.removeObject(forKey: "biometrics")
            
            self.logoff()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
            self.tableView.deselectRow(at: index, animated: true)
        }))
        
        self.present(alert, animated: true)
    }
    
    func showTerms(_ index: IndexPath) {
        self.presentAlert()
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?
        let destinationFileUrl = documentsUrl!.appendingPathComponent("terms.pdf")
        
        let fileURL = URL(string: "http://api.plandoc.com.br/v1/terms")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        var request = URLRequest(url: fileURL!)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data, error == nil, let response = response as? HTTPURLResponse {
                print("Successfully downloaded. Status code: \(response.statusCode)")
                
                do {
                    try data.write(to: destinationFileUrl)
                    print(data)
                } catch let error {
                    print("An error occurred while moving file to destination url \(error)")
                }
                
                DispatchQueue.main.async {
                    print(destinationFileUrl.absoluteString)
                    print("File exists? \(FileManager.default.fileExists(atPath: destinationFileUrl.absoluteString))")
                    
                    self.path = destinationFileUrl
                    
                    self.performSegue(withIdentifier: "SeguePrefsToPdf", sender: self)
                    
                    self.dismissCustomAlert()
                    
                    self.tableView.deselectRow(at: index, animated: true)
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "");
            }
        }
        
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SeguePrefsToPdf") {
            let vc = segue.destination as! PdfViewerController
            vc.path = path
        }
    }
    
    func checkFacebook(_ index: IndexPath, _ txt: UILabel) {
        var hasFacebook = false
        for info in Auth.auth().currentUser!.providerData {
            if info.providerID == "facebook.com" {
                hasFacebook = true
                break
            }
        }
        
        if hasFacebook {
            self.tableView.deselectRow(at: index, animated: true)
            
            return
        }
        
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let _, let _, let _):
                
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                Auth.auth().currentUser?.link(with: credential, completion: { (user, err) in
                    txt.text = "Vinculado ao Facebook"
                })
            }
        })
    }
}
