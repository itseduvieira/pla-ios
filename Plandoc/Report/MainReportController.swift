//
//  MainReportController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 15/12/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import UIKit
import Charts

class MainReportController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var navBar: UINavigationBar!
    //@IBOutlet weak var chart: LineChartView!
    var months: [String]!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //chart.noDataText = "Não existem dados para exibição"
        
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        self.setNavigationBar()
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
    }
}
