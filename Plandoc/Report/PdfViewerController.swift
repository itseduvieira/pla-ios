//
//  PdfViewer.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 19/01/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import WebKit

class PdfViewerController: UIViewController, WKNavigationDelegate {
    //MARK: Properties
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var path: URL!
    
    //MARK: Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
    
        webView.navigationDelegate = self
        webView.loadFileURL(path, allowingReadAccessTo: path)
    }
    
    func setNavigationBar() {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backItem
        let doneItem = UIBarButtonItem(title: "Download", style: .done, target: self, action: #selector(download))
        //navItem.rightBarButtonItem = doneItem
    }
    
    @objc func back() {
        self.performSegue(withIdentifier: "SegueUnwindToReport", sender: self)
    }
    
    @objc func download() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    func canRotate() -> Void {}
}
