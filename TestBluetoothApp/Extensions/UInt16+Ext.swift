//
//  UInt16+Ext.swift
//  TestBluetoothApp
//
//  Created by Anna on 25.06.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit

extension UInt16 {
    
    func convertToUInt8() -> [UInt8] {
        let int16Value = Int16(bitPattern: self)
        //
        let UInt8Value1 = UInt8(int16Value >> 8)
        let UInt8Value2 = UInt8(int16Value & 0x00ff)
        //
        return [UInt8Value1, UInt8Value2]
    }
    
}
