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
    
    case writeUpdateSound   = 0x0040        // 4
//    case writeSample        = 0x0041        // 4 ????
    case writeRulesSound    = 0x0042        // 4
//    case writeModesSound    = 0x0043        // 4 ????
    //
    case deleteSound    = 0x0046        // 5
    case listenSample   = 0x0041        // 6 ----
    //
    case settingsSound  = 0x0043        // 7 ----
    case idSounds       = 0x0047        // 8
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
        
    }
}

/// Чтение ID установленных звуковых пакетов (8)
struct ReadIDSounds: CommandProtocol {
    var u16Command: CommandsU16 = .idSounds
    let data = CommandsU16.idSounds.arrU8.toDataWithCRC()
}

/// Чтение пресетов (9)
struct ReadPresets: CommandProtocol {
    var u16Command: CommandsU16 = .readPresets
    let data = CommandsU16.readPresets.arrU8.toDataWithCRC()
}
