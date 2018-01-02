//
//  CalendarController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 17/11/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate {
    //MARK: Properties
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableShifts: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var constraintCalendar: NSLayoutConstraint!
    
    var shifts: Array<Data>!
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        tableShifts.delegate = self
        tableShifts.dataSource = self
        
        calendar.delegate = self
        calendar.locale = Locale(identifier: "pt_BR")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        shifts = UserDefaults.standard.array(forKey: "shifts") as? Array<Data>
        
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
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shifts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShiftCell", for: indexPath) as! ShiftCustomCell

        let shift = self.shifts[indexPath.row]
        let shiftPdc = NSKeyedUnarchiver.unarchiveObject(with: shift) as! Shift
        cell.color.backgroundColor = self.colors[indexPath.row]
        //cell.company.text = String(shiftPdc.value)
        
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
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
}
