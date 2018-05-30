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
        super.viewDidLoad()
        
        UIView.animate(withDuration: 1) {
            self.imgCheck.alpha = 1
        }
    }
}
