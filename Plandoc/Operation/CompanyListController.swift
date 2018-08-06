//
//  CompanyListController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 01/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import PromiseKit

class CompanyListController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var companyTable: UITableView!
    @IBOutlet weak var headerCompanies: UIView!
    @IBOutlet weak var txtEmpty: UILabel!
    
    @IBAction func unwindToCompaniesList(segue: UIStoryboardSegue) {}
    
    var companies: [Data]!
    var id: String!
    var dictCompanies: [String:Data]!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        companyTable.dataSource = self
        companyTable.delegate = self
        
        headerCompanies.layer.addBorder(edge: .top, color: UIColor(hexString: "#26000000"), thickness: 0.3)
        headerCompanies.layer.addBorder(edge: .bottom, color: UIColor(hexString: "#26000000"), thickness: 0.3)
    }
    
    func reloadData(_ reloadTable: Bool) {
        dictCompanies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] ?? [:]
        self.companies = [Data](dictCompanies.values)
        
        txtEmpty.isHidden = !self.companies.isEmpty
        companyTable.isHidden = self.companies.isEmpty
        
        id = nil
        
        if reloadTable {
            companyTable.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData(true)
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let doneItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navItem.rightBarButtonItem = doneItem
    }
    
    @objc func add() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SegueListToCompany", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueListToCompany") {
            let vc = segue.destination as! CompanyController
            vc.sender = self
            vc.id = id
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.companies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyCell", for: indexPath) as! CompanyCustomCell
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        
        let company = self.companies[indexPath.row]
        let companyPdc = NSKeyedUnarchiver.unarchiveObject(with: company) as! Company
        
        if let color = companyPdc.color {
            cell.color.backgroundColor = UIColor(hexString: color)
        }
        
        cell.company.text = "\(companyPdc.type!) \(companyPdc.name!)"
        cell.place.text = companyPdc.address
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let company = self.companies[indexPath.row]
        let companyPdc = NSKeyedUnarchiver.unarchiveObject(with: company) as! Company
        self.id = companyPdc.id
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SegueListToCompany", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let alert = UIAlertController(title: "Remover Empresa", message: "Ao remover uma empresa, seus dados e plantões serão removidos e não poderão ser recuperados. Você deseja realmente remover esta empresa e seus plantões?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Sim, desejo remover", style: .destructive, handler: { action in
                let company = self.companies[indexPath.row]
                let companyPdc = NSKeyedUnarchiver.unarchiveObject(with: company) as! Company
                
                self.deleteCompany(companyPdc, indexPath, tableView)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func deleteCompany(_ companyPdc: Company, _ indexPath: IndexPath, _ tableView: UITableView) {
        self.presentAlert()
        
        firstly {
            DataAccess.instance.deleteCompany(companyPdc.id)
        }.then {
            DataAccess.instance.deleteShiftsByCompany(companyPdc.id)
        }.done {
            var shifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
            shifts = shifts.filter({ (key, value) -> Bool in
                let pdcShift = NSKeyedUnarchiver.unarchiveObject(with: value) as! Shift
                return pdcShift.companyId != companyPdc.id
            })
            UserDefaults.standard.set(shifts, forKey: "shifts")
            
            self.dictCompanies.removeValue(forKey: companyPdc.id)
            UserDefaults.standard.set(self.dictCompanies, forKey: "companies")
            
            self.companies = [Data](self.dictCompanies.values)
            
            self.reloadData(false)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }.ensure {
            self.dismissCustomAlert()
        }.catch { error in
            self.showNetworkError (msg: "Não foi possível remover a Empresa. Verifique sua conexão com a Internet e tente novamente.", {
                self.deleteCompany(companyPdc, indexPath, tableView)
            })
        }
    }
}
