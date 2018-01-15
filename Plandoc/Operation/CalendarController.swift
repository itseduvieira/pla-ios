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
    @IBOutlet weak var calendarHeightConstant: NSLayoutConstraint!
    
    var shifts: [Data]!
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]
    var events: [String:Shift]!
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
        
        self.events = [:]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dict = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] {
            
            self.shifts = [Data](dict.values)
            
            for data in self.shifts {
                let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
                
                let formatter = DateFormatter()
                formatter.dateFormat = "ddMMyyyy"
                let id = formatter.string(from: shiftPdc.date)
                
                self.events[id] = shiftPdc
            }
            
            tableShifts.reloadData()
        } else {
            self.shifts = []
        }
        
        self.loadCalendarEvents()
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
            calendar.appearance.titleFont = UIFont(descriptor: calendar.appearance.titleFont.fontDescriptor, size: 18)
            
            constraintCalendar.constant = 92
            
            navItem.leftBarButtonItem?.title = "Mês"
        } else {
            calendar.scope = .month
            
            calendar.appearance.titleFont = UIFont(descriptor: calendar.appearance.titleFont.fontDescriptor, size: 12)
            
            constraintCalendar.constant = 240
            
            navItem.leftBarButtonItem?.title = "Semana"
        }
        
        
        self.updateViewConstraints()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if calendar.selectedDate == date {
            calendar.deselect(date)
            
            return false
        }
        
        return true
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
        cell.weekDay.text = dateFormatter.string(from: shiftPdc.date)
        
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
            
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstant.constant = bounds.size.height
        
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, hasEventFor date: Date) -> Bool {
        if let events = self.events {
            let formatter = DateFormatter()
            formatter.dateFormat = "ddMMyyyy"
            let id = formatter.string(from: date as Date)
            
            return events[id] != nil
        }
        
        return false
    }
    
    private func loadCalendarEvents() {
        for shift in self.shifts {
            let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: shift) as! Shift
            //calendar.
        }
    }
}
