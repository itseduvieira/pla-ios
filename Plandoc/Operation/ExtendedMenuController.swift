//
//  ExtendedMenuController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 01/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class ExtendedMenuController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableMenu: UITableView!
    
    @IBAction func unwindToExtendedMenu(segue: UIStoryboardSegue) {}
    
    let menu = ["Empresas", "Despesas", "Meta Financeira", "Plandoc Premium", "Preferências"]
    let icons = [UIImage(named: "IconBarCompany"), UIImage(named: "IconBarExpenses"), UIImage(named: "IconBarPayment"), UIImage(named: "IconBarPremium"), UIImage(named: "IconBarPreferences")]
    let segue = ["SegueCompanies", "SegueExpenses", "SegueGoals", "SegueMembership", "SeguePreferences"]
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableMenu.dataSource = self
        tableMenu.delegate = self
        
        self.setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectionIndexPath = self.tableMenu.indexPathForSelectedRow {
            self.tableMenu.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCustomCell
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        
        cell.menu.text = self.menu[indexPath.row]
        
        let templateImage = self.icons[indexPath.row]?.withRenderingMode(.alwaysTemplate)
        cell.icon.image = templateImage
        cell.icon.tintColor = UIColor.darkGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: segue[indexPath.row], sender: self)
    }
}
