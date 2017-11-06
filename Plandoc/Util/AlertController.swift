//
//  AlertController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 06/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class AlertController: UIViewController {
    //MARK: Properties
    var customView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    //MARK: Actions
    override func viewDidLoad() {
        mainView.addSubview(customView)
    }
}
