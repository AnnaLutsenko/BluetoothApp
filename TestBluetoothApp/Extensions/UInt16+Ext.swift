//
//  UInt16+Ext.swift
//  TestBluetoothApp
//
//  Created by Anna on 25.06.2018.
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

extension UInt16 {
    
    func convertToUInt8() -> [UInt8] {
        let int16Value = abs(Int16(bitPattern: self))
        //
        let UInt8Value1 = UInt8(int16Value >> 8)
        let UInt8Value2 = UInt8(int16Value & 0x00ff)
        //
        return [UInt8Value1, UInt8Value2]
    }
}

extension Array where Element == UInt8 {
    
    func toDataWithCRC() -> Data {
        let dataInCRC16 = CRC16.crc16(self, type: .MODBUS)
        
        if dataInCRC16 != nil {
            let modbusStr = String(format: "0x%4X", dataInCRC16!)
            print("MODBUS = " + modbusStr)
        }
        guard let crc16InUInt8 = dataInCRC16?.convertToUInt8() else {return Data()}
        //
        var dataToSend = self
        dataToSend.append(crc16InUInt8[0])
        dataToSend.append(crc16InUInt8[1])
        //
        return NSData(bytes: dataToSend, length: dataToSend.count) as Data
    }
    
    func subArray(fromIndex:Int, toIndex: Int) -> [UInt8] {
        return Array(self[fromIndex..<toIndex])
    }
}
