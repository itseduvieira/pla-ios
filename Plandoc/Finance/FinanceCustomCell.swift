//
//  FinanceCustomCell.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 09/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class FinanceCustomCell: UITableViewCell {
    @IBOutlet weak var color: UIView!
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet weak var constraintCompletion: NSLayoutConstraint!
    @IBOutlet weak var completion: UIView!
    @IBOutlet weak var left: UIView!
    @IBOutlet weak var scheduled: UILabel!
    @IBOutlet weak var paid: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var salaryPaid: UILabel!
    @IBOutlet weak var salaryLeft: UILabel!
    @IBOutlet weak var paidDesc: UILabel!
    @IBOutlet weak var leftDesc: UILabel!
    @IBOutlet weak var qdtPaidDesc: UILabel!
}
