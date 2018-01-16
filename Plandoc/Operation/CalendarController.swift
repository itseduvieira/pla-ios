//
//  CalendarController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 17/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource {
    //MARK: Properties
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableShifts: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var constraintCalendar: NSLayoutConstraint!
    
    var shifts: [Data]!
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]
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
        calendar.locale = Locale(identifier: "pt_BR")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
            for data in [Data](dict.values) {
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                
                let formatter = DateFormatter()
                formatter.dateFormat = "ddMMyyyy"
                let id = formatter.string(from: shiftPdc.date)
                
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
                var date = calendar.currentPage
                
                if calendar.selectedDate != nil {
                    date = calendar.selectedDate!
                    formatter.dateFormat = "ddMMyyyy"
                } else if calendar.scope == .month {
                    formatter.dateFormat = "MMyyyy"
                } else {
                    formatter.dateFormat = "ddMMyyyy"
                }
                
                return formatter.string(from: shiftPdc.date) == formatter.string(from: date)
            })).sorted(by: { (one, two) in
                let sOne = NSKeyedUnarchiver.unarchiveObject(with: one) as! Shift
                
                let sTwo = NSKeyedUnarchiver.unarchiveObject(with: two) as! Shift
                
                return sOne.date < sTwo.date
            })
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
        let calendarTypeItem = UIBarButtonItem(title: "Semana", style: .plain, target: self, action: #selector(changeCalendarType))
        navItem.leftBarButtonItem = calendarTypeItem
    }
    
    @objc func add() {
        self.id = nil
        self.performSegue(withIdentifier: "SegueCalendarToShift", sender: self)
    }
    
    @objc func changeCalendarType() {
        if calendar.scope == .month {
            calendar.scope = .week
            calendar.appearance.titleFont = UIFont(descriptor: calendar.appearance.titleFont.fontDescriptor, size: 16)
            
            navItem.leftBarButtonItem?.title = "Mês"
        } else {
            calendar.scope = .month
            
            calendar.appearance.titleFont = UIFont(descriptor: calendar.appearance.titleFont.fontDescriptor, size: 12)
            
            navItem.leftBarButtonItem?.title = "Semana"
        }
        
        self.viewWillAppear(true)
        self.updateViewConstraints()
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

        let shift = self.shifts[indexPath.row]
        let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: shift) as! Shift
        cell.color.backgroundColor = UIColor(hexString: shiftPdc.company.color)
        cell.company.text = "\(shiftPdc.company.type!) \(shiftPdc.company.name!)"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        cell.salary.text = formatter.string(from: shiftPdc.salary! as NSNumber)
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
        
        self.id = shiftPdc.id
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "SegueCalendarToShift", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if var dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
                
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: self.shifts[indexPath.row]) as! Shift
                dict.removeValue(forKey: shiftPdc.id)
                self.shifts.remove(at: indexPath.row)
                
                UserDefaults.standard.set(dict, forKey: "shifts")
                
                self.viewWillAppear(true)
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.constraintCalendar.constant = bounds.size.height
        
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, hasEventFor date: Date) -> Bool {
        if let events = self.events {
            let formatter = DateFormatter()
            formatter.dateFormat = "ddMMyyyy"
            let id = formatter.string(from: date as Date)
            
            return events.contains(id)
        }
        
        return false
    }
    
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
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.viewWillAppear(true)
    }
}
