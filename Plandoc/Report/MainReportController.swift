//
//  MainReportController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 15/12/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import Charts

class MainReportController: UIViewController, ChartViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtPeriod: UITextField!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var emptyText: UILabel!
    @IBOutlet weak var btnGenerateReport: UIRoundedButton!
    @IBOutlet weak var switchSend: UISwitch!
    
    @IBAction func unwindToReport(segue: UIStoryboardSegue) {}
    
    var path: URL!
    
    let months = ["jan", "fev", "mar", "abr", "mai", "jun",
                   "jul", "ago", "set", "out", "nov", "dez"]
    
    var companiesData: [Data]!
    var periodData = ["Mês Atual", "Últimos 30 Dias", "Personalizado"]
    var reportData: [ReportData]!
    
    var companyChoosed: Company!
    var picker: UIPickerView!
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        UITextField.connectFields(fields: [txtCompany, txtPeriod, txtStartDate, txtEndDate])
        
        self.applyBorders()
        
        self.hideKeyboardWhenTappedAround()
        
        setup(pieChartView: chartView)
        
        chartView.delegate = self
        
        let dictCompanies = UserDefaults.standard.dictionary(forKey: "companies") as? [String:Data] ?? [:]
        
        self.companiesData = [Data](dictCompanies.values)
        let allCompanies = Company()
        allCompanies.type = "Todas as"
        allCompanies.name = "Empresas"
        self.companiesData.insert(NSKeyedArchiver.archivedData(withRootObject: allCompanies), at: 0)
        
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        datePicker.locale = Locale(identifier: "pt_BR")
        txtStartDate.inputView = datePicker
        txtEndDate.inputView = datePicker
        
        self.setupDateField()
        
        txtCompany.text = "Todas as Empresas"
        txtPeriod.text = "Mês Atual"
        
        applyCurrentMonth()
    }
    
    private func applyCurrentMonth() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        let interval = Calendar.current.dateInterval(of: .month, for: Date())
        
        txtStartDate.text = formatter.string(from: interval!.start)
        txtEndDate.text = formatter.string(from: Calendar.current.date(byAdding: DateComponents(day: -1), to: interval!.end)!)
    }
    
    private func applyLast30Days() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        txtStartDate.text = formatter.string(from: Calendar.current.date(byAdding: DateComponents(day: -30), to: Date())!)
        txtEndDate.text = formatter.string(from: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dictShifts = UserDefaults.standard.dictionary(forKey: "shifts") as? [String:Data] ?? [:]
        reportData = [Data](dictShifts.values).filter({ (data) -> Bool in
            let shift = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let startDate = formatter.date(from: txtStartDate.text!)
            let endDate = formatter.date(from: txtEndDate.text!)
            
            var result = shift.date > startDate! && shift.date < endDate!
            
            if companyChoosed != nil {
                result = (result && companyChoosed.id == shift.company.id)
            }
            
            return result
        }).map { (data) -> ReportData in
            let shift = NSKeyedUnarchiver.unarchiveObject(with: data) as! Shift
            
            let report = ReportData()
            report.company = shift.company.name
            report.date = shift.date
            report.salary = shift.salary
            report.hours = shift.shiftTime
            
            return report
        }
        
        var entries: [PieChartDataEntry] = []
        
        if companyChoosed == nil {
            var group: [String:Double] = [:]
            
            for data in reportData {
                group[data.company] = group[data.company] ?? 0 + data.salary
            }
            
            entries = group.map { company, value in
                return PieChartDataEntry(value: value, label: company)
            }
        } else {
            var group: [String:Double] = [:]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMyyyy"
            
            for data in reportData {
                group[formatter.string(from: data.date)] = group[formatter.string(from: data.date)] ?? 0 + data.salary
            }
            
            for index in 1...12 {
                let key = String(format: "%02d", index) + "2018"
                if let element = group[key] {
                    entries.append(PieChartDataEntry(value: element,
                                             label: months[index - 1]))
                }
            }
        }
        
        emptyText.isHidden = !entries.isEmpty
        chartView.isHidden = entries.isEmpty
        btnGenerateReport.isHidden = entries.isEmpty
        
        self.updateChartData(entries)
    }
    
    @IBAction func generateReport() {
        do {
            self.presentAlert()
            
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?
            let destinationFileUrl = documentsUrl!.appendingPathComponent("report.pdf")
            
            let fileURL = URL(string: "http://pdc-api.herokuapp.com/v1/report")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            var request = URLRequest(url: fileURL!)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            var data: [[String]] = []
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.locale = Locale(identifier: "pt_BR")
            
            var total = 0.0
            var hours = 0
            
            for rd in reportData {
                total += rd.salary
                hours += rd.hours
                
                data.append([rd.company, formatter.string(from: rd.date), formatter.string(from: Calendar.current.date(byAdding: DateComponents(hour: rd.hours), to: rd.date)!), String(rd.hours), nf.string(for: rd.salary)!])
            }
            
            guard let user = UserDefaults.standard.object(forKey: "loggedUser") else {
                return
            }
            
            let pdcUser = NSKeyedUnarchiver.unarchiveObject(with: user as! Data) as! User
            
            let body: [String:Any] = [
                "name": pdcUser.name,
                "email": pdcUser.email,
                "startDate": txtStartDate.text!,
                "endDate": txtEndDate.text!,
                "total": nf.string(for: total)!,
                "hours": String(hours),
                "send": switchSend.isOn,
                "data": data
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if let data = data, error == nil, let response = response as? HTTPURLResponse {
                    print("Successfully downloaded. Status code: \(response.statusCode)")
                    
                    do {
                        try data.write(to: destinationFileUrl)
                        print(data)
                    } catch let error {
                        print("An error occurred while moving file to destination url \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        print(destinationFileUrl.absoluteString)
                        print("File exists? \(FileManager.default.fileExists(atPath: destinationFileUrl.absoluteString))")

                        self.path = destinationFileUrl
                        
                        self.performSegue(withIdentifier: "SegueReportToPdf", sender: self)
                        
                        self.dismissCustomAlert()
                    }
                    
                } else {
                    print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "");
                }
            }
            
            task.resume()
        } catch let error {
            print("An error occurred while send report request \(error)")
            
            self.dismissCustomAlert()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueReportToPdf") {
            let vc = segue.destination as! PdfViewerController
            vc.path = path
        }
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
    }
    
    private func applyBorders() {
        txtCompany.applyBottomBorder()
        txtPeriod.applyBottomBorder()
        txtStartDate.applyBottomBorder()
        txtEndDate.applyBottomBorder()
    }
    
    func updateChartData(_ entries: [PieChartDataEntry]?) {
        self.setDataCount(entries!)
    }
    
    func setDataCount(_ entries: [PieChartDataEntry]) {
        let set = PieChartDataSet(values: entries, label: "")
        set.sliceSpace = 1
        set.selectionShift = 5
        set.colors = [UIColor(hexString: "E93F33"), UIColor(hexString: "9C3FB0"), UIColor(hexString: "663AB6"), UIColor(hexString: "3D50B3"), UIColor(hexString: "2E94F2"), UIColor(hexString: "3FA8F4"), UIColor(hexString: "53BBD4"), UIColor(hexString: "459587"), UIColor(hexString: "59AF4F"), UIColor(hexString: "8AC149"), UIColor(hexString: "CCDA38"), UIColor(hexString: "FDE93B"), UIColor(hexString: "F7BF32"), UIColor(hexString: "F09533")]
        
        let data = PieChartData(dataSet: set)
        
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 8)!)
        data.setValueTextColor(.white)
        let nf = NumberFormatter()
        nf.currencySymbol = "R$"
        nf.numberStyle = .none
        data.setValueFormatter(DefaultValueFormatter(formatter: nf))
        
        chartView.data = data
        
        chartView.setNeedsDisplay()
    }
    
    func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = false
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.4
        chartView.transparentCircleRadiusPercent = 0.45
        chartView.chartDescription?.enabled = false
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .center
        chartView.legend.verticalAlignment = .top
        chartView.legend.font = UIFont(name:"HelveticaNeue-Light", size:10)!
        chartView.setExtraOffsets(left: 20, top: -40, right: 20, bottom: 0)
        chartView.drawCenterTextEnabled = false
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0
        chartView.rotationEnabled = true
        chartView.highlightPerTapEnabled = true
        chartView.drawEntryLabelsEnabled = false
        chartView.holeColor = .white
        chartView.transparentCircleColor = NSUIColor.white.withAlphaComponent(0.43)
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = true
        chartView.maxAngle = 180
        chartView.rotationAngle = 180
        chartView.entryLabelColor = .white
        chartView.entryLabelFont = UIFont(name:"HelveticaNeue-Light", size:10)!
    }
    
    @IBAction func showPicker(_ sender: UITextField) {
        pickUp(txtField: sender)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if txtCompany.isFirstResponder {
            return companiesData.count
        } else if txtPeriod.isFirstResponder {
            return periodData.count
        }
        
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if txtCompany.isFirstResponder {
            let company = NSKeyedUnarchiver.unarchiveObject(with: companiesData[row]) as! Company
            return "\(company.type!) \(company.name!)"
        } else if txtPeriod.isFirstResponder {
            return periodData[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if txtCompany.isFirstResponder {
            let company = NSKeyedUnarchiver.unarchiveObject(with: companiesData[row]) as! Company
            self.companyChoosed = row == 0 ? nil : company
            txtCompany.text = "\(company.type!) \(company.name!)"
        } else if txtPeriod.isFirstResponder {
            txtPeriod.text = periodData[row]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            
            switch row {
            case 0:
                applyCurrentMonth()
                break
            case 1:
                applyLast30Days()
                break
            default:
                print("Error at select period")
            }
        }
        
        viewWillAppear(true)
    }
    
    @objc func doneClick() {
        if txtCompany.isFirstResponder {
            txtPeriod.becomeFirstResponder()
        } else if txtPeriod.isFirstResponder {
            if txtPeriod.text == "Personalizado" {
                txtStartDate.becomeFirstResponder()
            } else {
                txtPeriod.resignFirstResponder()
            }
        }
    }
    
    func pickUp(txtField: UITextField) {
        self.picker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.picker.delegate = self
        self.picker.dataSource = self
        
        txtField.inputView = self.picker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtField.inputAccessoryView = toolBar
        
        if txtField.text!.isEmpty {
            self.picker.delegate?.pickerView!(self.picker, didSelectRow: 0, inComponent: 0)
        }
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if txtStartDate.isFirstResponder {
            txtStartDate.text = formatter.string(from: sender.date)
        } else if txtEndDate.isFirstResponder {
            txtEndDate.text = formatter.string(from: sender.date)
        }
        
        txtPeriod.text = "Personalizado"
        
        viewWillAppear(true)
    }
    
    private func setupDateField() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Escolher", style: .done, target: self, action: #selector(doneDate))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtStartDate.inputAccessoryView = toolBar
        txtEndDate.inputAccessoryView = toolBar
    }
    
    @objc func doneDate() {
        if txtStartDate.isFirstResponder {
            txtEndDate.becomeFirstResponder()
        } else if txtEndDate.isFirstResponder {
            txtEndDate.resignFirstResponder()
        }
    }
}
