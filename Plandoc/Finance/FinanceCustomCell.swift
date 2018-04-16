//
//  FinanceCustomCell.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 09/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class FinanceCustomCell: UITableViewCell {
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet weak var constraintCompletion: NSLayoutConstraint!
    @IBOutlet weak var completion: UIView!
    @IBOutlet weak var left: UIView!
    @IBOutlet weak var scheduled: UILabel!
    @IBOutlet weak var salaryPaid: UILabel!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var iconGoal: UIImageView!
    @IBOutlet weak var iconForward: UIImageView!
}
