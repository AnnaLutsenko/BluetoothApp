//
//  Data+Ext.swift
//  TestBluetoothApp
//
//  Created by Anna on 7/22/18.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit

extension Data {
    
    func convertToHEX() -> String {
        let bytes = [UInt8](self)
        var string = ""
        
        for val in bytes {
            //getBytes(&byte, range: NSMakeRange(i, 1))
            string = string + String(format: "%02X", val)
        }
        
        return string
    }
}
