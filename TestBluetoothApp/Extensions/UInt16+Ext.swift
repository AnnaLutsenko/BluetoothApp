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
        let intVal = Int16(truncatingIfNeeded: self)
        let int16Value = UInt16(bitPattern: intVal)//Int16(exactly: self) ?? 0)
        //
        let UInt8Value1 = UInt8(int16Value >> 8)
        let UInt8Value2 = UInt8(int16Value & 0x00ff)
        //
        return [UInt8Value1, UInt8Value2]
    }
}

extension Int {
    func convertToUInt8() -> [UInt8] {
        let uNv = UInt16(bitPattern: Int16(self))
        return [UInt8(uNv >> 8), UInt8(uNv & 0x00ff)]
//        return UInt16(self).convertToUInt8()
    }
}
