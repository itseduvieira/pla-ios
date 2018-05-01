//LargeAlertView
//  LargeAlertView.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 01/05/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class LargeAlertView: UIView {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var width: NSLayoutConstraint!
    
    weak var parent: UIViewController!
    
    @IBAction func close(_ sender: Any) {
        self.parent.dismissLargeAlert()
    }
}
