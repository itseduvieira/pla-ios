//
//  File.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 18/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class FinanceDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableShifts: UITableView!
    @IBOutlet weak var txtTotalShifts: UILabel!
    @IBOutlet weak var txtTotalProfit: UILabel!
    @IBOutlet weak var txtProfitPaid: UILabel!
    
    @IBAction internal func unwindToFinanceDetail(segue: UIStoryboardSegue) {}
    
    var shifts: [Data]!
    var id: String!
    var idShift: String!
    
    // MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        tableShifts.delegate = self
        tableShifts.dataSource = self
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMyyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        let month = formatter.date(from: self.id)
        formatter.dateFormat = "MMMM 'de' yyyy"
        navItem.title = formatter.string(from: month!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
            
            self.shifts = [Data](dict.values.filter({data in
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMyyyy"
                
                return formatter.string(from: shiftPdc.paymentDueDate) == self.id
            })).sorted(by: { (one, two) in
                let sOne = NSKeyedUnarchiver.unarchiveObject(with: one) as! Shift
                
                let sTwo = NSKeyedUnarchiver.unarchiveObject(with: two) as! Shift
                
                return sOne.paymentDueDate < sTwo.paymentDueDate
            })
        } else {
            self.shifts = []
        }
        
        var totalProfit = 0.0
        var profitPaid = 0.0
        
        for data in self.shifts {
            let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
            totalProfit += shiftPdc.salary
            if shiftPdc.paid {
                profitPaid += shiftPdc.salary
            }
        }
        
        txtTotalShifts.text = String(self.shifts.count)
        
//        if totalProfit > 1000 {
//            if totalProfit.truncatingRemainder(dividingBy: 1000) == 0 {
//                txtTotalProfit.text = "R$\(Int(totalProfit / 1000))K"
//            } else {
//                txtTotalProfit.text = "R$\(String(format: "%.1f", totalProfit / 1000))K"
//            }
//        } else {
            txtTotalProfit.text = "R$\(Int(totalProfit))"
//        }
        
//        if profitPaid > 1000 {
//            if profitPaid.truncatingRemainder(dividingBy: 1000) == 0 {
//                txtProfitPaid.text = "R$\(Int(profitPaid / 1000))K"
//            } else {
//                txtProfitPaid.text = "R$\(String(format: "%.1f", profitPaid / 1000))K"
//            }
//        } else {
            txtProfitPaid.text = "R$\(Int(profitPaid))"
//        }
        
        tableShifts.reloadData()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueUnwindToFinance", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: self.shifts[indexPath.row]) as! Shift
        self.idShift = shiftPdc.id
        self.performSegue(withIdentifier: "SegueFinanceToShifts", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shifts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShiftCell", for: indexPath) as! ShiftCustomCell
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        
        let shift = self.shifts[indexPath.row]
        let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: shift) as! Shift
        cell.color.backgroundColor = UIColor(hexString: shiftPdc.company.color)
        cell.company.text = "\(shiftPdc.company.type!) \(shiftPdc.company.name!)"
        cell.salary.text = "R$\(Int(shiftPdc.salary!))"
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "pt_BR")
        let day = calendar.component(.day, from: shiftPdc.paymentDueDate)
        cell.day.text = String(format: "%02d", day)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        dateFormatter.locale = Locale(identifier: "pt_BR")
        cell.weekDay.text = dateFormatter.string(from: shiftPdc.paymentDueDate).uppercased()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        cell.desc.text = "\(dateFormatter.string(from: shiftPdc.date)) • Jornada de \(shiftPdc.shiftTime!) Horas"
        
        if shiftPdc.paid {
            cell.lblPaid.backgroundColor = UIColor(hexString: "#59AF4F")
            cell.lblPaid.text = "PAGO   "
        } else {
            
            if Calendar.current.date(byAdding: DateComponents(day: 1), to: shiftPdc.paymentDueDate)! < Date() {
                cell.lblPaid.backgroundColor = UIColor(hexString: "#E94362")
            } else {
                cell.lblPaid.backgroundColor = UIColor(hexString: "#AAAAAA")
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueFinanceToShifts" {
            let controller = segue.destination as! ShiftController
            controller.sender = self
            controller.id = self.idShift
        }
    }
}
