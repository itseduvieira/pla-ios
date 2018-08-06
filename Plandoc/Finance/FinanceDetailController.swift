//
//  File.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 18/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import UserNotifications
import PromiseKit

class FinanceDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableShifts: UITableView!
    @IBOutlet weak var txtTotalShifts: UILabel!
    @IBOutlet weak var txtTotalProfit: UILabel!
    @IBOutlet weak var txtProfitPaid: UILabel!
    @IBOutlet weak var headerSummary: UIView!
    @IBOutlet weak var headerDetail: UIView!
    
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
        
        headerSummary.layer.addBorder(edge: .top, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        headerSummary.layer.addBorder(edge: .bottom, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        
        headerDetail.layer.addBorder(edge: .top, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        headerDetail.layer.addBorder(edge: .bottom, color: UIColor(hexString: "#26000000"), thickness: 0.3)
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
        txtTotalProfit.text = "R$\(Int(totalProfit))"
        txtProfitPaid.text = "R$\(Int(profitPaid))"
        
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
        cell.lblPaid.setRadius(radius: 2)
        
        if shiftPdc.paid {
            cell.lblPaid.backgroundColor = UIColor(hexString: "#59AF4F")
            cell.lblPaid.text = "PAGO  "
        } else {
            cell.lblPaid.text = "PENDENTE   "
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let shift = self.shifts[editActionsForRowAt.row]
        let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: shift) as! Shift
        
        let delete = UITableViewRowAction(style: .destructive, title: "Apagar") { action, index in
            let alert = UIAlertController(title: "Plantão Não Realizado", message: "Este plantão não foi realizado e será apagado. Você deseja realmente remover este plantao?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Sim, desejo remover", style: .destructive, handler: { action in
                
                var dict = UserDefaults.standard.dictionary(forKey: "shifts") as! [String:Data]
                dict.removeValue(forKey: shiftPdc.id)
                
                UserDefaults.standard.set(dict, forKey: "shifts")
                
                self.viewWillAppear(true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        let pay = UITableViewRowAction(style: .normal, title: "Já Recebi") { action, index in
            var dict = UserDefaults.standard.dictionary(forKey: "shifts") as! [String:Data]
            shiftPdc.paid = true
            dict[shiftPdc.id] = NSKeyedArchiver.archivedData(withRootObject: shiftPdc)
            UserDefaults.standard.set(dict, forKey: "shifts")
            
            let center = UNUserNotificationCenter.current()
            center.removeDeliveredNotifications(withIdentifiers: [shiftPdc.id])
            center.removePendingNotificationRequests(withIdentifiers: [shiftPdc.id])
            
            self.viewWillAppear(true)
        }
        pay.backgroundColor = UIColor(hexString: "#59AF4F")
        
        var actions = [delete]
        
        if !shiftPdc.paid {
            actions.insert(pay, at: 0)
            
            delete.title = "Remover"
        }

        return actions
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let shift = self.shifts[indexPath.row]
        let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: shift) as! Shift
        
        let delete = UIContextualAction(style: .destructive, title: "Remover") { (action, view, handler) in
            let alert = UIAlertController(title: "Plantão Não Realizado", message: "Este plantão não foi realizado e será apagado. Você deseja realmente remover este plantao?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Sim, desejo remover", style: .destructive, handler: { action in
                if shiftPdc.groupId == nil{
                    self.deleteShift(shiftPdc, indexPath, tableView)
                } else {
                    let alert = UIAlertController(title: "Remover Plantão Fixo", message: "O plantão escolhido é do tipo fixo. Você deseja remover apenas este agendamento ou todos os agendamentos deste fixo?", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Apenas Este", style: .default, handler: { action in
                        self.deleteShift(shiftPdc, indexPath, tableView)
                    }))
                    alert.addAction(UIAlertAction(title: "Remover Todos", style: .destructive, handler: { action in
                        self.deleteShiftGroup(shiftPdc, indexPath, tableView)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
            handler(false)
        }
        
        let pay = UIContextualAction(style: .destructive, title: "Já Recebi") { (action, view, handler) in
            self.pay(shiftPdc.id)
            
            handler(false)
        }
        
        pay.backgroundColor = UIColor(hexString: "#59AF4F")
        
        var act = [delete]
        
        if !shiftPdc.paid {
            act.insert(pay, at: 0)
        }
        
        let config = UISwipeActionsConfiguration(actions: act)
        
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    func pay(_ id: String) {
        self.presentAlert()
        
        var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
        let pdcShift = NSKeyedUnarchiver.unarchiveObject(with: shifts[id]!) as! Shift
        pdcShift.paid = true
        
        firstly {
            DataAccess.instance.updateShift(pdcShift)
        }.done {
            let shift = NSKeyedArchiver.archivedData(withRootObject: pdcShift)
            shifts[pdcShift.id] = shift
            UserDefaults.standard.set(shifts, forKey: "shifts")
            
            let center = UNUserNotificationCenter.current()
            center.removeDeliveredNotifications(withIdentifiers: [id])
            center.removePendingNotificationRequests(withIdentifiers: [id])
            
            self.viewWillAppear(true)
        }.ensure {
            self.dismissCustomAlert()
        }.catch { error in
            
            self.showNetworkError(msg: "Não foi possível enviar os dados do Plantão. Verifique sua conexão com a Internet e tente novamente.", {
                self.pay(id)
            })
        }
    }
    
    func deleteShift(_ pdcShift: Shift, _ indexPath: IndexPath, _ tableView: UITableView) {
        self.presentAlert()
        
        firstly {
            DataAccess.instance.deleteShift(pdcShift.id)
        }.done {
            var dict = UserDefaults.standard.dictionary(forKey: "shifts") as! [String:Data]
            
            dict.removeValue(forKey: pdcShift.id)
            
            UserDefaults.standard.set(dict, forKey: "shifts")
            
            self.viewWillAppear(true)
            self.viewDidAppear(true)
        }.ensure {
            self.dismissCustomAlert()
        }.catch { error in
            self.showNetworkError (msg: "Não foi possível remover o Plantão. Verifique sua conexão com a Internet e tente novamente.", {
                self.deleteShift(pdcShift, indexPath, tableView)
            })
        }
    }
    
    func deleteShiftGroup(_ pdcShift: Shift, _ indexPath: IndexPath, _ tableView: UITableView) {
        self.presentAlert()
        
        firstly {
            DataAccess.instance.deleteShiftGroup(pdcShift.groupId)
        }.done {
            var dict = UserDefaults.standard.dictionary(forKey: "shifts") as! [String:Data]
            
            for data in dict.values {
                let s = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                if s.groupId == pdcShift.groupId {
                    dict.removeValue(forKey: s.id)
                }
            }
            
            UserDefaults.standard.set(dict, forKey: "shifts")
            
            self.viewWillAppear(true)
            self.viewDidAppear(true)
        }.ensure {
            self.dismissCustomAlert()
        }.catch { error in
            self.showNetworkError (msg: "Não foi possível remover os Plantões. Verifique sua conexão com a Internet e tente novamente.", {
                self.deleteShiftGroup(pdcShift, indexPath, tableView)
            })
        }
    }
}
