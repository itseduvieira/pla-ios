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
    @IBOutlet weak var mainContainer: UIView!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        mainContainer.setRadius(radius: 4)
        mainContainer.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.mainContainer.alpha = 1
        })
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(cancel))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func cancel() {
        self.performSegue(withIdentifier: "SegueUnwindToExtendedMenu", sender: self)
    }
}
