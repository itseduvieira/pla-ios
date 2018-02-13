//
//  PreferencesController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 13/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth

class PreferencesController: UITableViewController {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var switchNotifications: UISwitch!
    
    //MARK: Action
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(hexString: "#2F95F2")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.clear
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 2:
                eraseData(indexPath)
                
                break
            default:
                print("Row \(indexPath.row)")
            }
            
            break
        case 2:
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
            UserDefaults.standard.removeObject(forKey: "loggedUser")
            self.performSegue(withIdentifier: "SeguePreferencesToLogin", sender: self)
        } catch {
            
        }
    }
    
    func eraseData(_ index: IndexPath) {
        let alert = UIAlertController(title: "Remover Dados do Aplicativo", message: "Esta ação irá remover TODOS os dados do aplicativo. Deseja continuar?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sim, remover os dados", style: .destructive, handler: { action in
            UserDefaults.standard.removeObject(forKey: "shifts")
            UserDefaults.standard.removeObject(forKey: "companies")
            UserDefaults.standard.removeObject(forKey: "profile")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")
            self.logoff()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action in
            self.tableView.deselectRow(at: index, animated: true)
        }))
        
        self.present(alert, animated: true)
    }
}
