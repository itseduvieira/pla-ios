//
//  SynchronizeController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 28/05/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit
import PromiseKit

class SynchronizeController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var imgSync: UIImageView!
    
    var rotate = true
    
    //MARK: Actions
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1) {
            self.imgSync.alpha = 1
        }
        
        self.rotateView(targetView: self.imgSync)
        
        firstly {
            DataAccess.instance.deleteAll()
        }.then {
            DataAccess.instance.createPreferences()
        }.then {
            Promise { seal in
                let profile = UserDefaults.standard.object(forKey: "profile") as! Data
                let pdcProfile = NSKeyedUnarchiver.unarchiveObject(with: profile) as! Profile
                
                if pdcProfile.crm == nil {
                    seal.fulfill(())
                } else {
                    firstly {
                        DataAccess.instance.createProfile(pdcProfile)
                    }.done {
                        seal.fulfill(())
                    }.catch { error in
                        seal.reject(error)
                    }
                }
            }
        }.then {
            // companies
            when(fulfilled: (UserDefaults.standard.object(forKey: "companies") as! [String:Data]).values.map({ company -> Promise<Void> in
                let pdcCompany = NSKeyedUnarchiver.unarchiveObject(with: company) as! Company
                return Promise { seal in
                    firstly {
                        DataAccess.instance.createCompany(pdcCompany)
                    }.done {
                        seal.fulfill(())
                    }.catch { error in
                        seal.reject(error)
                    }
                }
            }))
        }.then {
            // shifts
            when(fulfilled: (UserDefaults.standard.object(forKey: "shifts") as! [String:Data]).values.map({ shift -> Promise<Void> in
                let pdcShift = NSKeyedUnarchiver.unarchiveObject(with: shift) as! Shift
                return Promise { seal in
                    firstly {
                        DataAccess.instance.createShift(pdcShift)
                    }.done {
                        seal.fulfill(())
                    }.catch { error in
                        seal.reject(error)
                    }
                }
            }))
        }.then {
            // expsenses
            when(fulfilled: (UserDefaults.standard.object(forKey: "expenses") as! [String:Data]).values.map({ expense -> Promise<Void> in
                let pdcExpense = NSKeyedUnarchiver.unarchiveObject(with: expense) as! Expense
                return Promise { seal in
                    firstly {
                        DataAccess.instance.createExpense(pdcExpense)
                    }.done {
                        seal.fulfill(())
                    }.catch { error in
                        seal.reject(error)
                    }
                }
            }))
        }.then {
            Promise { seal in
                firstly {
                    DataAccess.instance.setPreference("online", true)
                }.done {
                    UserDefaults.standard.set(true, forKey: "online")
                    
                    seal.fulfill(())
                }.catch { error in
                    seal.reject(error)
                }
            }
        }.done {
            self.rotate = false
        }.catch { error in
            print(error)
            
            self.rotate = false
        }
    }
    
    private func rotateView(targetView: UIView, duration: Double = 1.7) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: .pi)
        }) { finished in
            if self.rotate {
                self.rotateView(targetView: targetView, duration: duration)
            } else {
                targetView.transform = .identity
                self.imgSync.image = UIImage(named: "IconCheck.png")
                
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.performSegue(withIdentifier: "SegueSyncToCalendar", sender: self)
                }
            }
        }
    }
}
