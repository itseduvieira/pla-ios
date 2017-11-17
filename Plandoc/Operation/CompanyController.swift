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
import MapboxGeocoder

class CompanyController : UIViewController {
    //MARK: Properties
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtAddress: SearchTextField!
    @IBOutlet weak var txtAdmin: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var selectedColor: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    weak var sender: UIViewController!
    var geocoder: Geocoder!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPictureRound()
        
        self.hideKeyboardWhenTappedAround()
        
        self.applyBorders()
        
        //self.setupAddressField()
        
        self.setNavigationBar()
        
        geocoder = Geocoder.shared
    }
    
    @IBAction func save() {
        var companies: Array<Data>
        
        if let companiesSaved = UserDefaults.standard.array(forKey: "companies") as? Array<Data> {
            companies = companiesSaved
        } else {
            companies = Array()
        }
        
        let pdcCompany = Company()
        pdcCompany.name = txtCompany.text
        pdcCompany.address = txtAddress.text
        pdcCompany.admin = txtAdmin.text
        pdcCompany.phone = txtPhone.text
        
        let company = NSKeyedArchiver.archivedData(withRootObject: pdcCompany)
        companies.append(company)
        UserDefaults.standard.set(companies, forKey: "companies")
        
        cancel()
    }
    
    @objc func cancel() {
        if self.sender.restorationIdentifier == "FirstStepsViewController" {
            self.performSegue(withIdentifier: "SegueCompanyToFirstSteps", sender: self)
        }
    }
    
    private func setupPictureRound() {
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
    }
    
    private func applyBorders() {
        txtCompany.applyBottomBorder()
        txtAddress.applyBottomBorder()
        txtAdmin.applyBottomBorder()
        txtPhone.applyBottomBorder()
    }
    
    private func setupAddressField() {
        txtAddress.startVisibleWithoutInteraction = true
        
        txtAddress.userStoppedTypingHandler = {
            if let criteria = self.txtAddress.text {
                if criteria.count > 2 {
                    
                    // Show loading indicator
                    self.txtAddress.showLoadingIndicator()
                    
                    self.filterAcronymInBackground(criteria) { results in
                        // Set new items to filter
                        self.txtAddress.filterItems(results)
                        
                        // Stop loading indicator
                        self.txtAddress.stopLoadingIndicator()
                    }
                }
            }
        } as (() -> Void)
    }
    
    fileprivate func filterAcronymInBackground(_ criteria: String, callback: @escaping ((_ results: [SearchTextFieldItem]) -> Void)) {
//        let url = URL(string: "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=\(criteria)")
//
//        if let url = url {
//            let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
//                do {
//                    if let data = data {
//                        let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:AnyObject]]
//
//                        if let firstElement = jsonData.first {
//                            let jsonResults = firstElement["lfs"] as! [[String: AnyObject]]
//
//                            var results = [SearchTextFieldItem]()
//
//                            for result in jsonResults {
//                                results.append(SearchTextFieldItem(title: result["lf"] as! String, subtitle: criteria.uppercased(), image: UIImage(named: "acronym_icon")))
//                            }
//
//                            DispatchQueue.main.async {
//                                callback(results)
//                            }
//                        } else {
//                            DispatchQueue.main.async {
//                                callback([])
//                            }
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            callback([])
//                        }
//                    }
//                }
//                catch {
//                    print("Network error: \(error)")
//                    DispatchQueue.main.async {
//                        callback([])
//                    }
//                }
//            })
//
//            task.resume()
//        }
        
        let options = ForwardGeocodeOptions(query: criteria)
        
        options.allowedISOCountryCodes = ["BR"]
//        options.focalLocation = CLLocation(latitude: 45.3, longitude: -66.1)
        options.allowedScopes = [.address, .pointOfInterest]
        
        let task = geocoder.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            
            print(placemark.name)
            print(placemark.qualifiedName)
            
            let coordinate = placemark.location.coordinate
            print("\(coordinate.latitude), \(coordinate.longitude)")
            
            var results = [SearchTextFieldItem]()
            
            for result in placemarks! {
                results.append(SearchTextFieldItem(title: result.name, subtitle: result.qualifiedName))
            }
            
            DispatchQueue.main.async {
                callback(results)
            }
        }
        
        //task.resume()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(cancel))
        navItem.leftBarButtonItem = backItem
        let doneItem = UIBarButtonItem(title: "Salvar", style: .plain, target: self, action: #selector(save))
        navItem.rightBarButtonItem = doneItem
    }
}
