//
//  ExpensesController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/02/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class ExpensesController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBAction func unwindToExpenses(segue: UIStoryboardSegue) {}
    
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
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func add() {
//        self.id = nil
        self.performSegue(withIdentifier: "SegueExpensesToDetail", sender: self)
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueUnwindToExtendedMenu", sender: self)
    }
}
