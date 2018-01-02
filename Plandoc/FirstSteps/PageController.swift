//
//  FirstPaController.swift
//  VisualNoAr
//
//  Created by Eduardo Vieira on 18/09/17.
//  Copyright © 2017 Visual no Ar. All rights reserved.
//

import UIKit

class PageController: UIViewController {
    //MARK: Properties    
    weak var parentVC: TutorialController!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showNextPage(_ sender: Any) {
        parentVC?.nextPage()
    }
    
    @IBAction func goToMenu() {
        UserDefaults.standard.removeObject(forKey: "activation")
        
        self.performSegue(withIdentifier: "SegueTutorialToMenu", sender: self)
    }    
}
