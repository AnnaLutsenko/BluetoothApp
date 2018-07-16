//
//  Commands.swift
//  TestBluetoothApp
//
//  Created by Anna on 16.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit

enum CommandsU16: UInt16 {
    
    case readParameters = 0x0001       // 2
    case updateFirmware = 0x0050       // 3
    
    case writeUpdateSound   = 0x0040   // 4.1
    case writeSample        = 0x0041   // 4.2
    case writeRulesSound    = 0x0042   // 4.3
    case writeSettingsSound = 0x0043   // 4.4 & 7
    //
    case deleteSound    = 0x0046        // 5
    case listenSample   = 0x0020        // 6
    //
    case readIDSounds   = 0x0047        // 8
    //
    case readPresets    = 0x0031        // 9
    case writePresets   = 0x0030        // 10
    case selectPreset   = 0x0045        // 11
    //
    case muteON         = 0x0048        // 12
    case muteOF         = 0x0049        // 13
    //
    case readCAN        = 0x004A        // 14
    case writeToCAN     = 0x004B        // 15
    //
    case poyling        = 0x0008        // 16
    
    /// Get array of UInt8 from selected command
    var arrU8: [UInt8] {
        return self.rawValue.convertToUInt8()
    }
}


/// Чтение параметров устройства (2)
struct ReadParameters: CommandProtocol {
    var u16Command: CommandsU16 = .readParameters
    let data = CommandsU16.readParameters.arrU8.toDataWithCRC()
}

struct ResponseReadParameters: CommandResponse {
    init(from data: Data) {
        parseData(data)
        //
        let val = [UInt8](data)
        
        if val.count >= 10 {
            //
            let hexValCommand = CRC16.bytesConvertToHexString(val.subArray(fromIndex: 0, toIndex: 2))
            let hexValueNumber = CRC16.bytesConvertToHexString(val.subArray(fromIndex: 2, toIndex: 4))
            let hexValVersionFW = CRC16.bytesConvertToInt16(val.subArray(fromIndex: 4, toIndex: 6))
            let hexValVersionHW = CRC16.bytesConvertToInt16(val.subArray(fromIndex: 6, toIndex: 8))
            let hexValCRC16 = CRC16.bytesConvertToHexString(val.subArray(fromIndex: 8, toIndex: 10))
            //
            print("HEX command = \(hexValCommand)")
            print("HEX serial number = \(hexValueNumber)")
            print("u16 version FW = \(hexValVersionFW)")
            print("u16 version HW = \(hexValVersionHW)")
            print("HEX CRC16= \(hexValCRC16)")
        }
    }
}

/// Чтение ID установленных звуковых пакетов (8)
struct ReadIDSounds: CommandProtocol {
    var u16Command: CommandsU16 = .readIDSounds
    let data = CommandsU16.readIDSounds.arrU8.toDataWithCRC()
}

/// Чтение пресетов (9)
struct ReadPresets: CommandProtocol {
    var u16Command: CommandsU16 = .readPresets
    let data = CommandsU16.readPresets.arrU8.toDataWithCRC()
}
