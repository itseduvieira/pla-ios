//
//  ExpenseDetailController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 28/02/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class ExpenseDetailController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var imgPicture: UIImageView!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.setNavigationBar()
    }
    
    private func setupPictureRound() {
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
        let doneItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(save))
        navItem.rightBarButtonItem = doneItem
    }
    
    @objc func save() {
        
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueUnwindToExpenses", sender: self)
    }
}
