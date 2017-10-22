//
//  Extensions.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 12/10/17.
//  Copyright © 2017 Plandoc. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    class func connectFields(fields:[UITextField]) -> Void {
        guard let last = fields.last else {
            return
        }
        
        for i in 0 ..< fields.count - 1 {
            fields[i].returnKeyType = .next
            fields[i].addTarget(fields[i+1], action: #selector(UIResponder.becomeFirstResponder), for: .editingDidEndOnExit)
        }
        
        last.returnKeyType = .done
        last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), for: .editingDidEndOnExit)
    }
    
    func applyBottomBorder() {
        let border = CALayer()
        let width = CGFloat(0.5)
        
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        self.leftView = paddingView
        self.rightView = paddingView
        self.leftViewMode = .always
        self.rightViewMode = .always
    }
}

class UIRoundedButton : UIButton {
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.setRadius(radius: 20)
    }
}

extension UIView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
    func setRadius(radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.width / 2;
        self.layer.masksToBounds = true;
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIImage {
    public func rotate(degrees: CGFloat, flip: Bool, completion: @escaping (UIImage) -> Void) {
        
        DispatchQueue.main.async {
            
            
            //        let radiansToDegrees: (CGFloat) -> CGFloat = {
            //            return $0 * (180.0 / CGFloat(Double.pi))
            //        }
            
            let degreesToRadians: (CGFloat) -> CGFloat = {
                return $0 / 180.0 * CGFloat(Double.pi)
            }
            
            // calculate the size of the rotated view's containing box for our drawing space
            let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: self.size))
            let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
            rotatedViewBox.transform = t
            let rotatedSize = rotatedViewBox.frame.size
            
            // Create the bitmap context
            UIGraphicsBeginImageContext(rotatedSize)
            let bitmap = UIGraphicsGetCurrentContext()
            
            // Move the origin to the middle of the image so we will rotate and scale around the center.
            bitmap!.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
            
            //   // Rotate the image context
            bitmap!.rotate(by: degreesToRadians(degrees));
            
            // Now, draw the rotated/scaled image into the context
            var yFlip: CGFloat
            
            if(flip){
                yFlip = CGFloat(-1.0)
            } else {
                yFlip = CGFloat(1.0)
            }
            
            bitmap!.scaleBy(x: yFlip, y: -1.0)
            bitmap!.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            completion(newImage!)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

