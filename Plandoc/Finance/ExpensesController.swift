//
//  ExpensesController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/02/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class ExpensesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var txtEmpty: UILabel!
    
    @IBAction func unwindToExpenses(segue: UIStoryboardSegue) {}
    
    enum TableSection: Int {
        case jan = 0, fev, mar, abr, mai, jun, jul, ago, set, out, nov, dez, total
    }
    
    // This is the size of our header sections that we will use later on.
    let SectionHeaderHeight: CGFloat = 40
    var selectedHeader: Int!
    
    var expenses: [String:Data]!
    
    // Data variable to track our sorted data.
    var data = [TableSection: [Expense]]()
    
    var id: String!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        table.dataSource = self
        table.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        data = [:]
        expenses = UserDefaults.standard.dictionary(forKey: "expenses") as? [String:Data] ?? [:]
        
        txtEmpty.isHidden = !expenses.isEmpty
        table.isHidden = expenses.isEmpty
        
        for ex in expenses.values {
            let pdcExpense = NSKeyedUnarchiver.unarchiveObject(with: ex) as! Expense
            let formatter = DateFormatter()
            formatter.dateFormat = "MM"
            let month = Int(formatter.string(from: pdcExpense.date))! - 1
            
            if data[TableSection(rawValue: month)!] == nil {
                data[TableSection(rawValue: month)!] = []
            }
            
            data[TableSection(rawValue: month)!]!.append(pdcExpense)
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
        self.performSegue(withIdentifier: "SegueExpensesToDetail", sender: self)
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
        self.performSegue(withIdentifier: "SegueExpensesToDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableSection = TableSection(rawValue: section), let movieData = data[tableSection] {
            return movieData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection = TableSection(rawValue: section), let movieData = data[tableSection], movieData.count > 0 {
            if selectedHeader != nil && section == selectedHeader {
                return SectionHeaderHeight + 100
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
        
        let img = UIImageView(image: UIImage(named: "IconFinanceUp.png"))
        img.frame = CGRect(x: tableView.bounds.width - 32, y: 8, width: 22, height: 22)
        
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
        view.addSubview(img)
        
        return view
    }
    
    @objc func clickHeader(_ sender: UIGestureRecognizer) {
        let current = sender.view!.tag - 100
        selectedHeader = (selectedHeader != nil && selectedHeader == current) ? nil : current
        table.beginUpdates()
        table.endUpdates()
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
                    let alert = UIAlertController(title: "Remover Plantão", message: "Ao remover um plantão, os dados não poderão ser recuperados. Você deseja realmente remover este plantao?", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Sim, desejo remover", style: .destructive, handler: { action in
                        
                        self.removeOne(expensePdc)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Remover Plantão Fixo", message: "O plantão escolhido é do tipo fixo. Você deseja remover apenas este agendamento ou todos os agendamentos deste fixo?", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Apenas Este", style: .default, handler: { action in
                        self.removeOne(expensePdc)
                    }))
                    alert.addAction(UIAlertAction(title: "Remover Todos", style: .destructive, handler: { action in
                        
                        for data in dict.values {
                            let s = NSKeyedUnarchiver.unarchiveObject(with: data) as! Expense
                            if s.groupId == expensePdc.groupId {
                                dict.removeValue(forKey: s.id)
                            }
                        }
                        
                        UserDefaults.standard.set(dict, forKey: "expenses")
                        
                        self.viewWillAppear(true)
                        self.viewDidAppear(true)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
        
        return [delete]
    }
    
    func removeOne(_ expense: Expense) {
        var dict = UserDefaults.standard.dictionary(forKey: "expenses") as! [String:Data]
        dict.removeValue(forKey: expense.id)
        
        UserDefaults.standard.set(dict, forKey: "expenses")
        
        self.viewWillAppear(true)
    }
}
