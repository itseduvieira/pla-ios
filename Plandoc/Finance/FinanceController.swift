//
//  FinanceController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 16/12/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class FinanceController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    
    // MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
    }
}
