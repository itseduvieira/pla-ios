//
//  CompletionController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class CompletionController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var imgCheck: UIImageView!
    
    //MARK: Actions
    override func viewDidLoad() {
        UIView.animate(withDuration: 1) {
            self.imgCheck.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
