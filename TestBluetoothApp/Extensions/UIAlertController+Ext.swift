//
//  UIAlertController+Ext.swift
//  TestBluetoothApp
//
//  Created by Anna on 19.06.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func presentAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        viewController.present(alert, animated: true)
    }
}
