//
//  CalendarController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 17/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    //MARK: Properties
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableShifts: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var constraintCalendar: NSLayoutConstraint!
    @IBOutlet weak var emptyText: UILabel!
    
    @IBAction func unwindToCalendar(segue: UIStoryboardSegue) {}
    
    var shifts: [Data]!
    var colors: [String:[UIColor]]! = [:]
    var events: [String]! = []
    var id: String!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        tableShifts.delegate = self
        tableShifts.dataSource = self
        
        calendar.delegate = self
        calendar.dataSource = self
        calendar.clipsToBounds = true
        calendar.locale = Locale(identifier: "pt_BR")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.events = []
        self.colors = [:]
        
        if let dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
            for data in [Data](dict.values) {
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                
                let formatter = DateFormatter()
                formatter.dateFormat = "ddMMyyyy"
                let id = formatter.string(from: shiftPdc.date)
                
                if self.colors[id] == nil {
                    self.colors[id] = []
                }
                
                self.colors[id]!.append(UIColor(hexString: shiftPdc.company.color))
                
                self.events.append(id)
            }
        }
        
        calendar.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
            
            self.shifts = [Data](dict.values.filter({data in
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                
                let formatter = DateFormatter()
                formatter.dateFormat = "ddMMyyyy"
                
                var date = calendar.currentPage
                
                if calendar.selectedDate != nil {
                    date = calendar.selectedDate!
                } else if calendar.scope == .month {
                    formatter.dateFormat = "MMyyyy"
                }
                
                return formatter.string(from: shiftPdc.date) == formatter.string(from: date)
            })).sorted(by: { (one, two) in
                let sOne = NSKeyedUnarchiver.unarchiveObject(with: one) as! Shift
                
                let sTwo = NSKeyedUnarchiver.unarchiveObject(with: two) as! Shift
                
                return sOne.date < sTwo.date
            })
            
            tableShifts.isHidden = self.shifts.isEmpty
            emptyText.isHidden = !self.shifts.isEmpty
        } else {
            self.shifts = []
        }
        
        tableShifts.reloadData()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let doneItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navItem.rightBarButtonItem = doneItem
        let calendarTypeItem = UIBarButtonItem(title: "Hoje", style: .plain, target: self, action: #selector(changeCalendarType))
        navItem.leftBarButtonItem = calendarTypeItem
    }
    
    @objc func add() {
        self.id = nil
        self.performSegue(withIdentifier: "SegueCalendarToShift", sender: self)
    }
    
    @objc func changeCalendarType() {
//        if calendar.scope == .month {
//            calendar.scope = .week
//            calendar.appearance.titleFont = UIFont(descriptor: calendar.appearance.titleFont.fontDescriptor, size: 16)
//
//            navItem.leftBarButtonItem?.title = "Mês"
//        } else {
//            calendar.scope = .month
//
//            calendar.appearance.titleFont = UIFont(descriptor: calendar.appearance.titleFont.fontDescriptor, size: 12)
//
//            navItem.leftBarButtonItem?.title = "Semana"
//        }
//
//        self.viewWillAppear(true)
//        self.updateViewConstraints()
        
        calendar.setCurrentPage(Date(), animated: true)
        self.viewWillAppear(true)
        self.viewDidAppear(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueCalendarToShift" {
            let controller = segue.destination as! ShiftController
            controller.sender = self
            controller.id = self.id
        }
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
        let day = calendar.component(.day, from: shiftPdc.date)
        cell.day.text = String(format: "%02d", day)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        dateFormatter.locale = Locale(identifier: "pt_BR")
        cell.weekDay.text = dateFormatter.string(from: shiftPdc.date).uppercased()
        dateFormatter.dateFormat = "HH:mm"
        cell.desc.text = "\(dateFormatter.string(from: shiftPdc.date)) • Jornada de \(shiftPdc.shiftTime!) Horas"
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        cell.lblPaid.text = "\(dateFormatter.string(from: shiftPdc.paymentDueDate))   "
        
        if shiftPdc.paid {
            cell.lblPaid.backgroundColor = UIColor(hexString: "#59AF4F")
        } else {
            if Calendar.current.date(byAdding: DateComponents(day: 1), to: shiftPdc.paymentDueDate)! < Date() {
                cell.lblPaid.backgroundColor = UIColor(hexString: "#E94362")
            } else {
                cell.lblPaid.backgroundColor = UIColor(hexString: "#AAAAAA")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: self.shifts[indexPath.row]) as! Shift
        self.id = shiftPdc.id
        self.performSegue(withIdentifier: "SegueCalendarToShift", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if var dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
                
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: self.shifts[indexPath.row]) as! Shift
                
                if shiftPdc.groupId == nil {
                    self.removeOne(shiftPdc)
                } else {
                    let alert = UIAlertController(title: "Remover Plantão Fixo", message: "O plantão escolhido é do tipo fixo. Você deseja remover apenas este agendamento ou todos os agendamentos deste fixo?", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Apenas Este", style: .default, handler: { action in
                        self.removeOne(shiftPdc)
                    }))
                    alert.addAction(UIAlertAction(title: "Remover Todos", style: .destructive, handler: { action in

                            for data in dict.values {
                                let s = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                                if s.groupId == shiftPdc.groupId {
                                    dict.removeValue(forKey: s.id)
                                }
                            }
                    
                            UserDefaults.standard.set(dict, forKey: "shifts")
                    
                            self.viewWillAppear(true)
                            self.viewDidAppear(true)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func removeOne(_ shift: Shift) {
        var dict = UserDefaults.standard.dictionary(forKey: "shifts") as! [String:Data]
        dict.removeValue(forKey: shift.id)
        
        UserDefaults.standard.set(dict, forKey: "shifts")
        
        self.viewWillAppear(true)
        self.viewDidAppear(true)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.constraintCalendar.constant = bounds.size.height
        
        self.view.layoutIfNeeded()
    }
    
    /*func calendar(_ calendar: FSCalendar, hasEventFor date: Date) -> Bool {
        if let events = self.events {
            let formatter = DateFormatter()
            formatter.dateFormat = "ddMMyyyy"
            let id = formatter.string(from: date as Date)
            
            return events.contains(id)
        }
        
        return false
    }*/
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.viewWillAppear(true)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if calendar.selectedDate == date {
            calendar.deselect(date)
            
            self.viewWillAppear(true)
            
            return false
        }
        
        return true
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var count = 0
        
        if let events = self.events {
            let formatter = DateFormatter()
            formatter.dateFormat = "ddMMyyyy"
            let id = formatter.string(from: date as Date)
            
            for event in events {
                if event == id {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.viewWillAppear(true)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        
        return self.colors[formatter.string(from: date)]
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        
        return self.colors[formatter.string(from: date)]
    }
}
