//
//  Array<UInt8>+Ext.swift
//  TestBluetoothApp
//
//  Created by Anna on 7/22/18.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit

extension Array where Element == UInt16 {
    
    func convertToUInt8() -> [UInt8] {
        var arrUInt8 = [UInt8]()
        for u16 in self {
            arrUInt8.append(u16.convertToUInt8())
        }
        return arrUInt8
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
    
    /// GET HEX from bytes in UInt8
    func convertToHEX() -> String {
        var string = ""
        
        for val in self {
            //getBytes(&byte, range: NSMakeRange(i, 1))
            string = string + String(format: "%02X", val)
        }
        
        return string
    }
    
    // GET Int16 from two bytes UInt8
    func convertToInt16() -> UInt16 {
        let u16 = UnsafePointer(self).withMemoryRebound(to: UInt16.self, capacity: 1) {
            $0.pointee
        }
        return u16.bigEndian
    }
    
    func subArray(fromIndex:Int, toIndex: Int) -> [UInt8] {
        return Array(self[fromIndex..<toIndex])
    }
    
    mutating func append(_ array: [UInt8]) {
        self = self + array
    }
}
