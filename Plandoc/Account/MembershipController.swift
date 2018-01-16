//
//  MembershipController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 16/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class MembershipController: UIViewController {
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
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(cancel))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func cancel() {
        self.performSegue(withIdentifier: "SeguePaymentToExtended", sender: self)
    }
}
