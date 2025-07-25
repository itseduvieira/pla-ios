//
//  ExpensesController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/02/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import PromiseKit

class ExpensesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var txtEmpty: UILabel!
    @IBOutlet weak var txtTitleYear: UILabel!
    @IBOutlet weak var btnHeaderYear: UIView!
    
    @IBAction func unwindToExpenses(segue: UIStoryboardSegue) {}
    
    enum TableSection: Int {
        case jan = 0, fev, mar, abr, mai, jun, jul, ago, set, out, nov, dez, total
    }
    
    // This is the size of our header sections that we will use later on.
    let SectionHeaderHeight: CGFloat = 55
    var selectedHeader: Int!
    
    var dictExpenses: [String:Data]!
    
    // Data variable to track our sorted data.
    var data = [TableSection: [Expense]]()
    
    var id: String!
    var year: String!
    var years: Set<String>! = []
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        table.dataSource = self
        table.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.displayYears(sender:)))
        btnHeaderYear.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if year == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            txtTitleYear.text! = "despesas de \(formatter.string(from: Date()))"
        }
        
        year = String(txtTitleYear.text!.split(separator: " ")[2])
        years = [year]
        
        data = [:]
        dictExpenses = UserDefaults.standard.dictionary(forKey: "expenses") as? [String:Data] ?? [:]
        
        txtEmpty.isHidden = !dictExpenses.isEmpty
        table.isHidden = dictExpenses.isEmpty
        
        dictExpenses = dictExpenses.filter { (key, value) -> Bool in
            let pdcExpense = NSKeyedUnarchiver.unarchiveObject(with: value) as! Expense
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            
            let y = formatter.string(from: pdcExpense.date)
            
            years.insert(y)
            
            let filtered = (y == year)
            
            if filtered {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM"
                let month = Int(formatter.string(from: pdcExpense.date))! - 1
                
                if data[TableSection(rawValue: month)!] == nil {
                    data[TableSection(rawValue: month)!] = []
                }
                
                data[TableSection(rawValue: month)!]!.append(pdcExpense)
            }
            
            return filtered
        }
        
        id = nil
        
        table.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueExpensesToDetail") {
            let vc = segue.destination as! ExpenseDetailController
            vc.id = id
        }
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let doneItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navItem.rightBarButtonItem = doneItem
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
    }
    
    @objc func add() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SegueExpensesToDetail", sender: self)
        }
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueUnwindToExtendedMenu", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.data[TableSection(rawValue: indexPath.section)!]
        self.id = section![indexPath.row].id
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SegueExpensesToDetail", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableSection = TableSection(rawValue: section), let movieData = data[tableSection] {
            return movieData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection = TableSection(rawValue: section), let movieData = data[tableSection], movieData.count > 0 {
            if UserDefaults.standard.bool(forKey: "goalActive") {
                if selectedHeader != nil && section == selectedHeader {
                    return SectionHeaderHeight + 100
                }
            }
            return SectionHeaderHeight
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        
        view.backgroundColor = UIColor(hexString: "#EBEBF1")
        view.layer.addBorder(edge: .top, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        view.layer.addBorder(edge: .bottom, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hexString: "#78000000")
        
        var total = 0
        for ex in dictExpenses.values {
            let pdcExpense = NSKeyedUnarchiver.unarchiveObject(with: ex) as! Expense
            let formatter = DateFormatter()
            formatter.dateFormat = "MM"
            let month = Int(formatter.string(from: pdcExpense.date))! - 1
            if month == section {
                total += Int(pdcExpense.value)
            }
        }
        
        if UserDefaults.standard.bool(forKey: "goalActive") {
            let goalValue = UserDefaults.standard.double(forKey: "goalValue")
            var totalIncome = 0
            
            if let dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
                for data in [Data](dict.values) {
                    let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMyyyy"
                    let reference = formatter.string(from: shiftPdc.paymentDueDate)
                    if reference == (String(format: "%02d", section + 1) + year) {
                        totalIncome += Int(shiftPdc.salary)
                    }
                }
            }

            let img = UIImageView(image: UIImage(named: ((totalIncome - total) >= Int(goalValue)) ? "IconFinanceUp.png" : "IconFinanceDown.png"))
            img.frame = CGRect(x: tableView.bounds.width - 28, y: 0, width: 22, height: SectionHeaderHeight)
            img.contentMode = .scaleAspectFit
            view.addSubview(img)
        }
        
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .jan:
                label.text = "JANEIRO"
            case .fev:
                label.text = "FEVEREIRO"
            case .mar:
                label.text = "MARÇO"
            case .abr:
                label.text = "ABRIL"
            case .mai:
                label.text = "MAIO"
            case .jun:
                label.text = "JUNHO"
            case .jul:
                label.text = "JULHO"
            case .ago:
                label.text = "AGOSTO"
            case .set:
                label.text = "SETEMBRO"
            case .out:
                label.text = "OUTUBRO"
            case .nov:
                label.text = "NOVEMBRO"
            case .dez:
                label.text = "DEZEMBRO"
            default:
                label.text = ""
            }
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(clickHeader(_:)))
            view.tag = tableSection.rawValue + 100
            view.addGestureRecognizer(gesture)
        }
        
        view.addSubview(label)
        
        let txtTotal = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 36, height: SectionHeaderHeight))
        txtTotal.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        txtTotal.textColor = UIColor(hexString: "#BB000000")
        txtTotal.text = "R$\(total)"
        txtTotal.textAlignment = .right
        view.addSubview(txtTotal)
        
        return view
    }
    
    @objc func displayYears(sender : UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Escolher Ano", message: "Escolha o ano de exibição desejado", preferredStyle: .actionSheet)
        
        for year in self.years.sorted() {
            alert.addAction(UIAlertAction(title: year, style: .default, handler: { action in
                self.txtTitleYear.text = "despesas de \(year)"
                self.viewWillAppear(true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @objc func clickHeader(_ sender: UIGestureRecognizer) {
//        let current = sender.view!.tag - 100
//        selectedHeader = (selectedHeader != nil && selectedHeader == current) ? nil : current
//        table.beginUpdates()
//        table.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let tableSection = TableSection(rawValue: indexPath.section), let expense = data[tableSection]?[indexPath.row] {
            
            if let titleLabel = cell.viewWithTag(10) as? UILabel {
                titleLabel.text = expense.title
            }
            if let subtitleLabel = cell.viewWithTag(20) as? UILabel {
                let formatter = DateFormatter()
                formatter.dateFormat = "'Dia' dd"
                subtitleLabel.text = formatter.string(for: expense.date)
            }
            if let circle = cell.viewWithTag(30) {
                circle.setRadius()
            }
            if let valueLabel = cell.viewWithTag(40) as? UILabel {
                valueLabel.text = "R$\(Int(expense.value))"
            }
            if let top = cell.viewWithTag(31) {
                let filteredConstraints = top.constraints.filter { $0.identifier == "WidthLine1" }
                if let width = filteredConstraints.first {
                    width.constant = 0.25
                }
                
                if indexPath.row == 0 {
                    top.isHidden = true
                } else {
                    top.isHidden = false
                }
            }
            
            if let bottom = cell.viewWithTag(32) {
                let filteredConstraints = bottom.constraints.filter { $0.identifier == "WidthLine2" }
                if let width = filteredConstraints.first {
                    width.constant = 0.25
                }
                
                if indexPath.row == ((data[tableSection]?.count)! - 1) {
                    bottom.isHidden = true
                } else {
                    bottom.isHidden = false
                }
            }
            
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Apagar") { action, index in
            if var dict = UserDefaults.standard.dictionary(forKey: "expenses") as? [String:Data] {
                
                let section = TableSection(rawValue: editActionsForRowAt.section)!
                
                let expensePdc = self.data[section]![editActionsForRowAt.row]
                
                if expensePdc.groupId == nil {
                    let alert = UIAlertController(title: "Remover Despesa", message: "Ao remover uma despesa, os dados não poderão ser recuperados. Você deseja realmente remover este despesa?", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Sim, desejo remover", style: .destructive, handler: { action in
                        self.deleteExpense(expensePdc, editActionsForRowAt, tableView)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Remover Despesa Fixa", message: "A despesa escolhida é do tipo fixa. Você deseja remover apenas este registro ou todos os agendamentos deste fixo?", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Apenas Este", style: .default, handler: { action in
                        self.deleteExpense(expensePdc, editActionsForRowAt, tableView)
                    }))
                    alert.addAction(UIAlertAction(title: "Remover Todos", style: .destructive, handler: { action in
                        self.deleteExpenseGroup(expensePdc, editActionsForRowAt, tableView)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
        
        return [delete]
    }
    
    func deleteExpense(_ expensePdc: Expense, _ indexPath: IndexPath, _ tableView: UITableView) {
        self.presentAlert()
        
        firstly {
            DataAccess.instance.deleteExpense(expensePdc.id)
        }.done {
            self.dictExpenses.removeValue(forKey: expensePdc.id)
            
            UserDefaults.standard.set(self.dictExpenses, forKey: "expenses")
            
            self.viewWillAppear(true)
        }.ensure {
            self.dismissCustomAlert()
        }.catch { error in
            self.showNetworkError (msg: "Não foi possível remover a Despesa. Verifique sua conexão com a Internet e tente novamente.", {
                self.deleteExpense(expensePdc, indexPath, tableView)
            })
        }
    }
    
    func deleteExpenseGroup(_ expensePdc: Expense, _ indexPath: IndexPath, _ tableView: UITableView) {
        self.presentAlert()
        
        firstly {
            DataAccess.instance.deleteExpenseGroup(expensePdc.groupId)
        }.done {
            for data in self.dictExpenses.values {
                let s = NSKeyedUnarchiver.unarchiveObject(with: data) as! Expense
                if s.groupId == expensePdc.groupId {
                    self.dictExpenses.removeValue(forKey: s.id)
                }
            }
            
            UserDefaults.standard.set(self.dictExpenses, forKey: "expenses")
            
            self.viewWillAppear(true)
            self.viewDidAppear(true)
        }.ensure {
            self.dismissCustomAlert()
        }.catch { error in
            self.showNetworkError (msg: "Não foi possível remover as Despesas. Verifique sua conexão com a Internet e tente novamente.", {
                self.deleteExpenseGroup(expensePdc, indexPath, tableView)
            })
        }
    }
}
