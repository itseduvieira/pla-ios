//
//  CompanyListController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 01/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class CompanyListController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let doneItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navItem.rightBarButtonItem = doneItem
        let calendarTypeItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = calendarTypeItem
    }
    
    @objc func add() {
        self.performSegue(withIdentifier: "SegueListToCompany", sender: self)
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueCompanyToMenu", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueListToCompany") {
            let vc = segue.destination as! CompanyController
            vc.sender = self
        }
    }
}
