//
//  BLERequest.swift
//  TestBluetoothApp
//
//  Created by Anna on 19.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation

class BLERequest {
    typealias Success = (CommandResponse)->()
    typealias Failure = (Error)->()
    //
    var command: CommandProtocol
    var success: Success
    var failure: Failure
    
    init(command: CommandProtocol, success: @escaping Success, failure: @escaping Failure) {
        self.command = command
        self.success = success
        self.failure = failure
    }
    
    /// check if response of peripheral is for current command
    ///
    /// - Parameter data: it's response of peripheral
    func isThisCommand(_ data: Data) -> Bool {
        let dataInU8 = [UInt8](data)
        return command.u16Command.arrU8[1] == dataInU8[1]
    }
    
    func isDataFull(_ data: Data) -> Bool {
        let bytes = [UInt8](data)
        //
        let previousByte = bytes[bytes.count-2]
        let lastByte = bytes[bytes.count-1]
        
        let hexValCRC16 = CRC16.bytesConvertToHexString([previousByte, lastByte])
        //
        let data = Array(bytes.prefix(bytes.count-2)) // data without CRC16
        guard let modbusValue = CRC16.crc16(data, type: .MODBUS) else { return false } // get CRC16 from data
        //
        let modbusStr = String(format: "%4X", modbusValue)
        debugPrint("MODBUS = \(modbusStr)")
        debugPrint("CRC16 = \(hexValCRC16)")
        //
        return hexValCRC16 == modbusStr
    }
}
