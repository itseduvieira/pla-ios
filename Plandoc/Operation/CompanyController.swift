//
//  CompanyController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 29/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import ChromaColorPicker
import SearchTextField
//import MapboxGeocoder

class CompanyController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Properties
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtType: UITextField!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtAddress: SearchTextField!
    @IBOutlet weak var txtAdmin: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var selectedColor: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var colorIndicator: UIView!
    @IBOutlet weak var stackColors: UIStackView!
    @IBOutlet weak var constraintTxtTipo: NSLayoutConstraint!
    @IBOutlet weak var constraintTxtName: NSLayoutConstraint!
    @IBOutlet weak var constraintHeader: NSLayoutConstraint!
    
    var picker: UIPickerView!
    
    weak var sender: UIViewController!
    var id: String!
//    var geocoder: Geocoder!
    
    let pickerTypeData = [
        "Clínica", "Hospital", "P. Socorro", "Outro"
    ]
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.hideKeyboardWhenTappedAround()
        
        self.applyBorders()
        
//        self.setupAddressField()
        
        self.setNavigationBar()
        
        self.setExistingCompany()
        
//        geocoder = Geocoder.shared
        
        UITextField.connectFields(fields: [txtCompany, txtAddress, txtAdmin, txtPhone])
        
        for v in stackColors.subviews {
            if let btn = v as? UIButton {
                btn.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
            }
        }
    
        if UIScreen.main.bounds.height < 500 {
            self.adjust4s()
        }
    }
    
    private func adjust4s() {
        imgPicture.isHidden = true
        constraintHeader.constant = 78
        constraintTxtTipo.constant = 94
        constraintTxtName.constant = 94
    }
    
    @IBAction func save() {
        if txtType.text! == "" || txtCompany.text! == "" || txtAddress.text! == "" || txtAdmin.text! == "" || txtPhone.text! == "" {
            let alertController = UIAlertController(title: "Erro", message: "Preencha corretamente os campos.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            var companies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] ?? [:]
            
            var pdcCompany: Company
            
            if !companies.isEmpty, id != nil {
                pdcCompany = NSKeyedUnarchiver.unarchiveObject(with: companies[id]!) as! Company
            } else {
                pdcCompany = Company()
                pdcCompany.id = String.random()
            }
            
            pdcCompany.type = txtType.text
            pdcCompany.name = txtCompany.text
            pdcCompany.address = txtAddress.text
            pdcCompany.admin = txtAdmin.text
            pdcCompany.phone = txtPhone.text
            pdcCompany.color = colorIndicator.backgroundColor?.hexCode
            pdcCompany.active = true
            
            let company = NSKeyedArchiver.archivedData(withRootObject: pdcCompany)
            
            companies[pdcCompany.id] = company
            
            UserDefaults.standard.set(companies, forKey: "companies")
            
            cancel()
        }
    }
    
    @objc func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueCompanyToFirstSteps", sender: self)
        } else if self.sender.restorationIdentifier == "ListCompaniesViewController" {
            self.performSegue(withIdentifier: "SegueUnwindToList", sender: self)
        } else if self.sender.restorationIdentifier == "ShiftsViewController" {
            self.performSegue(withIdentifier: "SegueCompanyToShift", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueCompanyToShift" {
            let controller = segue.destination as! ShiftController
            controller.sender = self
        }
    }
    
    private func setExistingCompany() {
        if id != nil, var companies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] {
            let company = NSKeyedUnarchiver.unarchiveObject(with: companies[id]!) as! Company
            txtType.text = company.type
            txtCompany.text = company.name
            txtAddress.text = company.address
            txtAdmin.text = company.admin
            txtPhone.text = company.phone
            if let color = company.color {
                colorIndicator.backgroundColor = UIColor(hexString: color)
            }
        }
    }
    
    private func setupPictureRound() {
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
    }
    
    private func applyBorders() {
        txtType.applyBottomBorder()
        txtCompany.applyBottomBorder()
        txtAddress.applyBottomBorder()
        txtAdmin.applyBottomBorder()
        txtPhone.applyBottomBorder()
    }
    
    private func setupAddressField() {
        txtAddress.theme = SearchTextFieldTheme.lightTheme()
        
        // Define a header - Default: nothing
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: txtAddress.frame.width, height: 30))
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        header.textAlignment = .center
        header.font = UIFont.systemFont(ofSize: 14)
        header.text = "Pick your option"
        txtAddress.resultsListHeader = header
        
        
        // Modify current theme properties
        txtAddress.theme.font = UIFont.systemFont(ofSize: 12)
        txtAddress.theme.bgColor = UIColor.lightGray.withAlphaComponent(0.2)
        txtAddress.theme.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        txtAddress.theme.separatorColor = UIColor.lightGray.withAlphaComponent(0.5)
        txtAddress.theme.cellHeight = 50
        txtAddress.theme.placeholderColor = UIColor.lightGray
        
        // Max number of results - Default: No limit
        txtAddress.maxNumberOfResults = 5
        
        // Max results list height - Default: No limit
        txtAddress.maxResultsListHeight = 200
        
        // Set specific comparision options - Default: .caseInsensitive
        txtAddress.comparisonOptions = [.caseInsensitive]
        
        // You can force the results list to support RTL languages - Default: false
        txtAddress.forceRightToLeft = false
        
        // Customize highlight attributes - Default: Bold
        txtAddress.highlightAttributes = [NSAttributedStringKey.backgroundColor: UIColor.yellow, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)]
        
        // Handle item selection - Default behaviour: item title set to the text field
        txtAddress.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            // Do whatever you want with the picked item
            self.txtAddress.text = item.title
        }
        
        txtAddress.userStoppedTypingHandler = {
            if let criteria = self.txtAddress.text {
                if criteria.count > 2 {
                    
                    // Show loading indicator
                    self.txtAddress.showLoadingIndicator()
                    
                    self.filterAddresses(criteria) { results in
                        // Set new items to filter
                        self.txtAddress.filterItems(results)
                        
                        // Stop loading indicator
                        self.txtAddress.stopLoadingIndicator()
                    }
                }
            }
        } as (() -> Void)
    }
    
    fileprivate func filterAddresses(_ criteria: String, callback: @escaping ((_ results: [SearchTextFieldItem]) -> Void)) {
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
        let key = URLQueryItem(name: "key", value: "AIzaSyCC9OmOfQL9HpICsN5irU42lNxPRNh10aE") // use your key
        let address = URLQueryItem(name: "address", value: criteria)
        components.queryItems = [key, address]
        
        if let url = components.url {
            let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
//                do {
                    if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                        
                        if let results = json["results"] as? [[String:AnyObject]], let address = results[0]["address_components"] as? [[String:AnyObject]] {
                            var items = [SearchTextFieldItem]()
                            
                            var number, street, city, state, neighboor: String?
                            
                            for component in address {
                                guard let types = component["types"] as? [String] else {
                                    continue
                                }
                                
                                if types.contains(where: { (type) -> Bool in
                                    return type == "route"
                                }) {
                                    street = component["short_name"] as? String
                                }
                                
                                if types.contains(where: { (type) -> Bool in
                                    return type == "street_number"
                                }) {
                                    number = component["short_name"] as? String
                                }
                                
                                if types.contains(where: { (type) -> Bool in
                                    return type == "sublocality_level_1"
                                }) {
                                    neighboor = component["short_name"] as? String
                                }
                                
                                if types.contains(where: { (type) -> Bool in
                                    return type == "administrative_area_level_2"
                                }) {
                                    city = component["short_name"] as? String
                                }
                                
                                if types.contains(where: { (type) -> Bool in
                                    return type == "administrative_area_level_1"
                                }) {
                                    state = component["short_name"] as? String
                                }
                            }
                            
                            let title = "\(street ?? ""), \(number ?? "")"
                            let subtitle = "\(neighboor ?? ""), \(city ?? "")  - \(state ?? "")"
                            
                            items.append(SearchTextFieldItem(title: title, subtitle: subtitle.uppercased()))
                            
                            DispatchQueue.main.async {
                                callback(items)
                            }
                        } else {
                            DispatchQueue.main.async {
                                callback([])
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            callback([])
                        }
                    }
//                } catch {
//                    print("Network error: \(error)")
//                    DispatchQueue.main.async {
//                        callback([])
//                    }
//                }
            })
            
            task.resume()
        }
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(cancel))
        navItem.leftBarButtonItem = backItem
        let doneItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(save))
        navItem.rightBarButtonItem = doneItem
    }
    
    @IBAction func chooseType() {
        self.pickUp()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if txtType.isFirstResponder {
            return pickerTypeData.count
        }
        
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if txtType.isFirstResponder {
            return pickerTypeData[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if txtType.isFirstResponder {
            txtType.text = pickerTypeData[row]
        }
    }
    
    @objc func doneClick() {
        if txtType.isFirstResponder {
            txtCompany.becomeFirstResponder()
        }
    }
    
    func pickUp() {
        self.picker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.picker.delegate = self
        self.picker.dataSource = self
        
        txtType.inputView = self.picker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtType.inputAccessoryView = toolBar
        
        if txtType.text!.isEmpty {
            self.picker.delegate?.pickerView!(self.picker, didSelectRow: 0, inComponent: 0)
        }
    }
    
    @objc func changeColor(sender: UIButton) {
        colorIndicator.backgroundColor = sender.backgroundColor
    }
}
