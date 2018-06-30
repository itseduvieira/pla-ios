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
    @IBOutlet weak var txtTotalShifts: UILabel!
    @IBOutlet weak var txtTotalProfit: UILabel!
    @IBOutlet weak var txtProfitPaid: UILabel!
    @IBOutlet weak var txtQtdCompanies: UILabel!
    @IBOutlet weak var txtProfitLeft: UILabel!
    @IBOutlet weak var headerSummary: UIView!
    @IBOutlet weak var headerMonths: UIView!
    @IBOutlet weak var labelMonths: UILabel!
    
    @IBAction func unwindToFinance(segue: UIStoryboardSegue) {}
    
    var financeData: [String:FinanceData]!
    var years: Set<String>! = []
    var companies: Set<String>! = []
    
    var id: String!
    
    // MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        tableFinance.delegate = self
        tableFinance.dataSource = self
        
        headerSummary.layer.addBorder(edge: .top, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        headerSummary.layer.addBorder(edge: .bottom, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        
        headerMonths.layer.addBorder(edge: .top, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        headerMonths.layer.addBorder(edge: .bottom, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        
		
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.financeData = [:]
		
		let goalActive = UserDefaults.standard.bool(forKey: "goalActive")
		labelMonths.text = goalActive ? "MESES (META ATIVA)" : "MESES"
        
        if let dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
            for data in [Data](dict.values) {
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMyyyy"
                let id = formatter.string(from: shiftPdc.paymentDueDate)
                
                years.insert(String(id.suffix(4)))
                companies.insert(shiftPdc.company.id)
                
                if id.hasSuffix((navItem.rightBarButtonItem?.title)!) {
                    if financeData[id] == nil {
                        financeData[id] = FinanceData()
                    }
                    
                    financeData[id]!.totalShifts = financeData[id]!.totalShifts + 1
                    financeData[id]!.salaryTotal = financeData[id]!.salaryTotal + shiftPdc.salary
                    
                    if shiftPdc.paid {
                        financeData[id]!.salaryPaid = financeData[id]!.salaryPaid + shiftPdc.salary
                        financeData[id]!.paidShifts = financeData[id]!.paidShifts + 1
                    }
                }
            }
        }
        
        var totalShifts = 0
        var totalProfit = 0.0
        var profitPaid = 0.0
        
        for index in 1...12 {
            let id =
                String(format: "%02d", index) + (navItem.rightBarButtonItem?.title)!
            
            if financeData[id] == nil {
                financeData[id] = FinanceData()
            } else {
                totalShifts += financeData[id]!.totalShifts
                totalProfit += financeData[id]!.salaryTotal
                profitPaid += financeData[id]!.salaryPaid
            }
        }
        
        txtTotalShifts.text = String(totalShifts)
        txtTotalProfit.text = "R$\(Int(totalProfit))"
        txtQtdCompanies.text = String(companies.count)
        txtProfitPaid.text = "R$\(Int(profitPaid))"
        txtProfitLeft.text = "R$\(Int(totalProfit - profitPaid))"
        
        tableFinance.reloadData()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        let yearItem = UIBarButtonItem(title: String(Calendar.current.dateComponents([.year], from: Date()).year!), style: .plain, target: self, action: #selector(displayYears))
        navItem.rightBarButtonItem = yearItem
    }
    
    @objc func displayYears() {
        let alert = UIAlertController(title: "Escolher Ano", message: "Escolha o ano de exibição desejado", preferredStyle: .actionSheet)
        
        for year in self.years.sorted() {
            alert.addAction(UIAlertAction(title: year, style: .default, handler: { action in
                self.navItem.rightBarButtonItem?.title = year
                self.viewWillAppear(true)
                self.tableFinance.reloadData()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = String(format: "%02d", indexPath.row + 1) + (navItem.rightBarButtonItem?.title)!
        
        let finance = financeData[id]
        
        if finance!.totalShifts > 0 {
            self.id = id
			
			DispatchQueue.main.async {
            	self.performSegue(withIdentifier: "SegueFinanceToDetail", sender: self)
			}
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.financeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FinanceCell", for: indexPath) as! FinanceCustomCell
        
        let goalActive = UserDefaults.standard.bool(forKey: "goalActive")
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        
        let df1 = DateFormatter()
        df1.dateFormat = "MMM"
        df1.locale = Locale(identifier: "pt_BR")
        
        let df2 = DateFormatter()
        df2.dateFormat = "MM"
        
        cell.smallLabel.text = df1.string(from: df2.date(from: String(format: "%02d", indexPath.row + 1))!).uppercased()
            
        if let finance = financeData[String(format: "%02d", indexPath.row + 1) + (navItem.rightBarButtonItem?.title)!] {
        
            cell.scheduled.text = "\(finance.totalShifts!) receita" + (finance.totalShifts! != 1 ? "s" : "")
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "pt_BR")
            
            if finance.totalShifts > 0 {
                let percent = CGFloat(finance.paidShifts) / CGFloat(finance.totalShifts)
                
                let screenSize = UIScreen.main.bounds
                let total = screenSize.width - 22
                
                if finance.paidShifts > 0 {
                    cell.constraintCompletion.constant = total * percent
                    UIView.animate(withDuration: 1, animations: {
                        cell.layoutIfNeeded()
                    }, completion: nil)
                } else {
                    cell.constraintCompletion.constant = 0
                }
                
                cell.salaryPaid.text = "R$\(Int(finance.salaryPaid)) (\(String(Int(percent * 100)))%) já recebidos"
                cell.salary.text = "R$\(Int(finance.salaryTotal))"
                
                cell.completion.isHidden = false
                cell.left.isHidden = false
            } else {
                cell.completion.isHidden = true
                cell.salaryPaid.text = "R$0 recebidos"
                cell.salary.text = "R$0"
            }
            
            if goalActive {
                let goalValue = UserDefaults.standard.double(forKey: "goalValue")
                
                let expenses = UserDefaults.standard.dictionary(forKey: "expenses") as? [String:Data] ?? [:]
                
                let hasGoal = UserDefaults.standard.bool(forKey: "goalActive")
                var accomplish = false
				
				var sum = 0.0
                
                for ex in expenses.values {
                    let pdcExpense = NSKeyedUnarchiver.unarchiveObject(with: ex) as! Expense
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMyyyy"
                    
                    let monthRow = String(format: "%02d", indexPath.row + 1) + navItem.rightBarButtonItem!.title!
                    if monthRow == formatter.string(from: pdcExpense.date) {
                        //hasGoal = true
						sum += pdcExpense.value
                    }
                }
				
				accomplish = (finance.salaryTotal - sum) >= goalValue
                
                cell.iconGoal.isHidden = !hasGoal
                cell.iconForward.isHidden = hasGoal
                
                if hasGoal {
                    cell.iconGoal.image = UIImage(named: accomplish ? "IconFinanceUp.png" : "IconFinanceDown.png")
                }
            }  else {
                cell.iconGoal.isHidden = true
                cell.iconForward.isHidden = false
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueFinanceToDetail") {
            let vc = segue.destination as! FinanceDetailController
            vc.id = id
        }
    }
}
