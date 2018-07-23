//
//  CRC16.swift
//  TestBluetoothApp
//
//  Created by Anna on 22.06.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation

enum CRCType {
    case MODBUS
    case ARC
}

class CRC16 {
    
    static func crc16(_ data: [UInt8], type: CRCType) -> UInt16? {
        if data.isEmpty {
            return nil
        }
        let polynomial: UInt16 = 0xA001 // A001 is the bit reverse of 8005
        var accumulator: UInt16
        // set the accumulator initial value based on CRC type
        if type == .ARC {
            accumulator = 0
        }
        else {
            // default to MODBUS
            accumulator = 0xFFFF
        }
        // main computation loop
        for byte in data {
            var tempByte = UInt16(byte)
            for _ in 0 ..< 8 {
                let temp1 = accumulator & 0x0001
                accumulator = accumulator >> 1
                let temp2 = tempByte & 0x0001
                tempByte = tempByte >> 1
                if (temp1 ^ temp2) == 1 {
                    accumulator = accumulator ^ polynomial
                }
            }
        }
        return accumulator
    }
    
}
