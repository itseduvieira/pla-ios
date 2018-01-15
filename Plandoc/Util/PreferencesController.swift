//
//  PreferencesController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 13/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import FirebaseAuth

class PreferenceController: UITableViewController {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    //MARK: Action
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(hexString: "#1D9DD5")
        }
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SeguePreferencesToCalendar", sender: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.clear
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
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
}
