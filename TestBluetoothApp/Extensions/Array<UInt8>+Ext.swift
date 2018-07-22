//
//  Array<UInt8>+Ext.swift
//  TestBluetoothApp
//
//  Created by Anna on 7/22/18.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit

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
    
    mutating func append(_ array: [UInt8]) {
        self = self + array
    }
}
