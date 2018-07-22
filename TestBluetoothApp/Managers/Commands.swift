
//
//  Commands.swift
//  TestBluetoothApp
//
//  Created by Anna on 16.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit

enum CommandsU16: UInt16 {
    
    case readParameters     = 0x0001   // 2
    case updateFirmware     = 0x0050   // 3
    case confirmationUpdate = 0x0051   // 3
    //
    case writeUpdateSound   = 0x0040   // 4.1
    case writeSample        = 0x0041   // 4.2
    case writeRulesSound    = 0x0042   // 4.3
    case writeSettingsSound = 0x0043   // 4.4 & 7
    case confirmRecordSound = 0x0044   // 4.5 Confirming the recording / updating of the sound package in the device //TODO: command
    //
    case startPlaySample    = 0x0020   // 6
    case stopListenSample   = 0x0021   // 6
    //
    case deleteSound    = 0x0046        // 5
    //
    case readIDSounds   = 0x0047        // 8
    //
    case readPresets    = 0x0031        // 9
    case writePresets   = 0x0030        // 10
    case selectPreset   = 0x0045        // 11
    //
    case muteON         = 0x0048        // 12
    case muteOFF        = 0x0049        // 13
    //
    case readCAN        = 0x004A        // 14
    case writeToCAN     = 0x004B        // 15
    //
    case poyling        = 0x0008        // 16
    
    /// Get array of UInt8 from selected command
    var arrU8: [UInt8] {
        return self.rawValue.convertToUInt8()
    }
    
    /// Get second Byte from selected command
    var secondByte: UInt8 {
        return self.rawValue.convertToUInt8()[1]
    }
}


/// 2 - Чтение параметров устройства
struct ReadParameters: CommandProtocol {
    var u16Command: CommandsU16 = .readParameters
    let data = CommandsU16.readParameters.arrU8.toDataWithCRC()
}

struct ResponseReadParameters: CommandResponse {
    var serialNumber = UInt16.min
    var firmware = UInt16.min
    var hardware = UInt16.min
    
    init(from data: Data) {
        //
        let val = [UInt8](data)
        
        if val.count == 10 {
            //
            serialNumber = val.subArray(fromIndex: 2, toIndex: 4).convertToInt16()
            firmware = val.subArray(fromIndex: 4, toIndex: 6).convertToInt16()
            hardware = val.subArray(fromIndex: 6, toIndex: 8).convertToInt16()
            //
            print("HEX serial number = \(serialNumber)")
            print("u16 version FW = \(firmware)")
            print("u16 version HW = \(hardware)")
            //
            parseData(data)
        }
    }
}

/// 5 - Удаление звукового пакета из устройства
struct DeleteSound: CommandProtocol {
    var u16Command: CommandsU16 = .deleteSound
    var data: Data
    
    init(soundID: UInt16) {
        var commandArr = u16Command.arrU8
        let u8ID = soundID.convertToUInt8()
        commandArr.append(u8ID)
        data = commandArr.toDataWithCRC()
        print("Delete sound: \(data.convertToHEX()))")
    }
}

struct ResponseDeleteSound: CommandResponse {
    
    init(from data: Data) {
        parseData(data)
    }
}

/// 6 - Прослушивание тестового сэмпла звукового пакета на устройстве
struct StartPlaySound: CommandProtocol {
    var u16Command: CommandsU16 = .startPlaySample
    var data: Data
    
    init(soundID: [UInt16]) {
        var commandArr = u16Command.arrU8
        let u8ID = soundID.convertToUInt8()
        commandArr.append(u8ID)
        data = commandArr.toDataWithCRC()
        print("Start Play sound: \(data.convertToHEX()))")
    }
}

struct ResponseStartPlaySound: CommandResponse {
    var soundID = UInt16.min
    var versionOfPackageID = UInt16.min
    
    init(from data: Data) {
        let val = [UInt8](data)
        if val.count == 8 {
            soundID = val.subArray(fromIndex: 2, toIndex: 4).convertToInt16()
            versionOfPackageID = val.subArray(fromIndex: 4, toIndex: 6).convertToInt16()
            //
            parseData(data)
        }
    }
}

/// 8 - Чтение ID установленных звуковых пакетов
struct ReadIDSounds: CommandProtocol {
    var u16Command: CommandsU16 = .readIDSounds
    let data = CommandsU16.readIDSounds.arrU8.toDataWithCRC()
}

struct ResponseReadIDSounds: CommandResponse {
    init(from data: Data) {
        parseData(data)
        //
    }
}

/// 9 - Чтение пресетов
struct ReadPresets: CommandProtocol {
    var u16Command: CommandsU16 = .readPresets
    let data = CommandsU16.readPresets.arrU8.toDataWithCRC()
}

struct ResponseReadPresets: CommandResponse {
    init(from data: Data) {
        parseData(data)
        //
    }
}

/// 11 - Выбор текущего Пресета в устройстве
struct SelectCurrentPreset: CommandProtocol {
    var u16Command: CommandsU16 = .selectPreset
    var data: Data
    
    init(presetID: UInt16) {
        var commandArr = u16Command.arrU8
        let u8ID = presetID.convertToUInt8()
        commandArr.append(u8ID)
        data = commandArr.toDataWithCRC()
        print("Select current preset: \(data.convertToHEX()))")
    }
}

struct ResponseSelectCurrentPreset: CommandResponse {
    var presetID = UInt16.min
    
    init(from data: Data) {
        let val = [UInt8](data)
        if val.count == 6 {
            presetID = val.subArray(fromIndex: 2, toIndex: 4).convertToInt16()
            //
            parseData(data)
        }
    }
}

/// 12 - Mute ON
struct MuteOn: CommandProtocol {
    var u16Command: CommandsU16 = .muteON
    let data = CommandsU16.muteON.arrU8.toDataWithCRC()
}

struct ResponseMuteOn: CommandResponse {
    init(from data: Data) {
        parseData(data)
        //
    }
}

/// 13 - Mute OFF
struct MuteOff: CommandProtocol {
    var u16Command: CommandsU16 = .muteOFF
    let data = CommandsU16.muteOFF.arrU8.toDataWithCRC()
}

struct ResponseMuteOff: CommandResponse {
    init(from data: Data) {
        parseData(data)
        //
    }
}

/// 14 - Reading ID and version parameters of CAN from peripheral
struct ReadCAN: CommandProtocol {
    var u16Command: CommandsU16 = .readCAN
    let data = CommandsU16.readCAN.arrU8.toDataWithCRC()
}

struct ResponseReadCAN: CommandResponse {
    var idCAN = UInt16.min
    var idVersion = UInt16.min
    
    init(from data: Data) {
        let val = [UInt8](data)
        if val.count == 8 {
            idCAN = val.subArray(fromIndex: 2, toIndex: 4).convertToInt16()
            idVersion = val.subArray(fromIndex: 4, toIndex: 6).convertToInt16()
            //
            parseData(data)
        }
    }
}

/// 16 - Команда пойлинга
struct Poyling: CommandProtocol {
    var u16Command: CommandsU16 = .poyling
    let data = CommandsU16.poyling.arrU8.toDataWithCRC()
}

struct ResponsePoyling: CommandResponse {
    var state = PeripheralState.busy
    var percent = UInt16.min
    
    init(from data: Data) {
        let val = [UInt8](data)
        if val.count == 8 {
            let byte2 = val.subArray(fromIndex: 2, toIndex: 4).convertToInt16()
            state = PeripheralState(rawValue: byte2)
            percent = val.subArray(fromIndex: 4, toIndex: 6).convertToInt16()
            //
            parseData(data)
        }
    }
}


/// Default response
struct ResponseDefault: CommandResponse {
    init(from data: Data) {
        parseData(data)
        //
    }
}
