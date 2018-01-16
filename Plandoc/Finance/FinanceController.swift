//
//  FinanceController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 16/12/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit

class FinanceController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableFinance: UITableView!
    
    var financeData: [String:FinanceData]! = [:]
    
    // MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        tableFinance.delegate = self
        tableFinance.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
            for data in [Data](dict.values) {
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMyyyy"
                let id = formatter.string(from: shiftPdc.paymentDueDate)
                
                if financeData[id] == nil {
                    financeData[id] = FinanceData()
                }
                
                financeData[id]!.totalShifts = financeData[id]!.totalShifts + 1
                financeData[id]!.salaryTotal = financeData[id]!.salaryTotal + shiftPdc.salary
                if shiftPdc.paid {
                    financeData[id]!.paidShifts = financeData[id]!.paidShifts + 1
                }
            }
        }
        
        for index in 1...12 {
            let id =
                String(format: "%02d", index) + "2018"
            
            if financeData[id] == nil {
                financeData[id] = FinanceData()
            }
        }
        
        tableFinance.reloadData()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        let yearItem = UIBarButtonItem(title: "2018", style: .plain, target: self, action: #selector(changeYear))
        navItem.rightBarButtonItem = yearItem
    }
    
    @objc func changeYear() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.financeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FinanceCell", for: indexPath) as! FinanceCustomCell
        
        let df1 = DateFormatter()
        df1.dateFormat = "MMM"
        df1.locale = Locale(identifier: "pt_BR")
        
        let df2 = DateFormatter()
        df2.dateFormat = "MM"
        
        cell.smallLabel.text = df1.string(from: df2.date(from: String(format: "%02d", indexPath.row + 1))!).uppercased()
            
        if let finance = financeData[String(format: "%02d", indexPath.row + 1) + "2018"] {
        
            cell.scheduled.text = String(finance.totalShifts)
            cell.paid.text = String(finance.paidShifts)
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "pt_BR")
            
            if finance.totalShifts > 0 {
                let notPaid = finance.salaryTotal - finance.salaryPaid
                
                let percentage = finance.paidShifts / finance.totalShifts * 100
                
                let barTotal = cell.left.intrinsicContentSize.width
                
                //cell.constraintCompletion.constant = barTotal * CGFloat(percentage) / 100
                cell.completion.isHidden = false
                cell.left.isHidden = false
                
                cell.paid.text = String(finance.paidShifts)
                cell.paid.isHidden = false
                cell.qdtPaidDesc.isHidden = false
                
                cell.salaryPaid.text = formatter.string(from: finance.salaryPaid as NSNumber)
                cell.salaryPaid.isHidden = false
                cell.paidDesc.isHidden = false
                
                cell.salaryLeft.text = formatter.string(from: notPaid as NSNumber)
                cell.salaryLeft.isHidden = false
                cell.leftDesc.isHidden = false
            }
        }
        
        return cell
    }
}
