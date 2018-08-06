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
    @IBOutlet weak var headerMenu: UIView!
    
    @IBAction func unwindToExtendedMenu(segue: UIStoryboardSegue) {}
    
    let menu = ["Despesas", "Meta Financeira", "Perfil", "Preferências"]
    let icons = [UIImage(named: "IconBarExpenses"), UIImage(named: "IconBarPayment"), UIImage(named: "IconBarProfile"), UIImage(named: "IconBarPreferences")]
    let segue = ["SegueExpenses", "SegueGoals", "SegueProfile", "SeguePreferences"]
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableMenu.dataSource = self
        tableMenu.delegate = self
        
        self.setNavigationBar()
        
        headerMenu.layer.addBorder(edge: .top, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        headerMenu.layer.addBorder(edge: .bottom, color: UIColor(hexString: "#26000000"), thickness: 0.3)
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
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.segue[indexPath.row], sender: self)
        }
    }
}
