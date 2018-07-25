
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
    case writeRulesOfSample = 0x0042   // 4.3
    case writeRulesOfSoundPackageMode = 0x0043   // 4.4 & 7
    case confirmRecordSound           = 0x0044   // 4.5 Confirming the recording / updating of the sound package in the device
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
    case writeCAN       = 0x004B        // 15
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

//MARK: - 2
/// 2 - Чтение параметров устройства
struct ReadParameters: CommandProtocol {
    var u16Command: CommandsU16 = .readParameters
    let data = CommandsU16.readParameters.arrU8.toDataWithCRC()
}

struct ResponseReadParameters: CommandResponse {
    var peripheral: PeripheralModel
    
    init(from data: Data) throws {
        //
        let val = [UInt8](data)
        
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 5 {
            //
            peripheral = PeripheralModel(serialNumber: arrUInt16[1], version: VersionModel(firmware: arrUInt16[2], hardware: arrUInt16[3]))
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

//MARK: - 3 Update Firmware
struct UpdateFirmware: CommandProtocol {
    var u16Command: CommandsU16 = .updateFirmware
    var data: Data
    
    init(device: DeviceType = .main, version: VersionModel, block: BlockModel, FW: [UInt8]) {
        var commandArr = u16Command.arrU8
        //
        commandArr.append(device.rawValue.convertToUInt8())
        commandArr.append(version.hardware.convertToUInt8())
        commandArr.append(version.firmware.convertToUInt8())
        //
        commandArr.append(block.count.convertToUInt8())
        commandArr.append(block.currentNumber.convertToUInt8())
        //
        commandArr.append(FW.count.convertToUInt8())
        commandArr.append(FW)
        //
        data = commandArr.toDataWithCRC()
    }
}

struct ConfirmationUpdate: CommandProtocol {
    var u16Command: CommandsU16 = .confirmationUpdate
    var data: Data
    
    init(device: DeviceType, version: VersionModel) {
        var commandArr = u16Command.arrU8
        //
        commandArr.append(device.rawValue.convertToUInt8())
        commandArr.append(version.hardware.convertToUInt8())
        commandArr.append(version.firmware.convertToUInt8())
        //
        data = commandArr.toDataWithCRC()
    }
}

struct ResponseConfirmationUpdate: CommandResponse {
    init(from data: Data) {
        parseData(data)
    }
}

//MARK: - 4

/// 4.1 - Команда запись/обновление звукового пакета
struct WriteUpdateSound: CommandProtocol {
    var u16Command: CommandsU16 = .writeUpdateSound
    var data: Data
    
    init(sound: SoundModel, sampleCount: Int, rulesCount: Int, modesCount: Int, rulesModeCount: Int) {
        var commandArr = u16Command.arrU8
        //
        commandArr.append(sound.id.convertToUInt8())
        commandArr.append(sound.versionID.convertToUInt8())
        commandArr.append(sampleCount.convertToUInt8())
        commandArr.append(rulesCount.convertToUInt8())
        commandArr.append(modesCount.convertToUInt8())
        commandArr.append(rulesModeCount.convertToUInt8())
        //
        data = commandArr.toDataWithCRC()
    }
}

struct ResponseWriteUpdateSound: CommandResponse {
    var sound: SoundModel
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 4 {
            //
            sound = SoundModel(id: arrUInt16[1], versionID: arrUInt16[2])
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

/// 4.3 - Запись правил семпла звукового пакета в устройство
struct WriteRulesOfSample: CommandProtocol {
    var u16Command: CommandsU16 = .writeRulesOfSample
    var data: Data
    
    init(sample: SampleModel, rules: [RuleModel]) {
        var commandArr = u16Command.arrU8
        //
        commandArr.append(sample.sound.id.convertToUInt8())
        commandArr.append(sample.sound.versionID.convertToUInt8())
        commandArr.append(sample.id.convertToUInt8())
        commandArr.append(rules.count.convertToUInt8())
        //
        for rule in rules {
            commandArr.append(rule.id.convertToUInt8())
            commandArr.append(rule.means.convertToUInt8())
        }
        //
        data = commandArr.toDataWithCRC()
    }
}

struct ResponseWriteRulesOfSample: CommandResponse {
    var sample: SampleModel
    var rulesCount: Int
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 6 {
            //
            let sound = SoundModel(id: arrUInt16[1], versionID: arrUInt16[2])
            sample = SampleModel(sound: sound, id: arrUInt16[3])
            rulesCount = Int(arrUInt16[4])
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

/// 4.4 (or 7) - Запись правил режимов звукового пакета в устройство
struct WriteRulesOfSoundPackageMode: CommandProtocol {
    var u16Command: CommandsU16 = .writeRulesOfSoundPackageMode
    var data: Data
    
    init(soundPackage: SoundPackageModel, rules: [RuleModel]) {
        var commandArr = u16Command.arrU8
        //
        commandArr.append(soundPackage.sound.id.convertToUInt8())
        commandArr.append(soundPackage.sound.versionID.convertToUInt8())
        commandArr.append(soundPackage.modeID.convertToUInt8())
        commandArr.append(rules.count.convertToUInt8())
        //
        for rule in rules {
            commandArr.append(rule.id.convertToUInt8())
            commandArr.append(rule.means.convertToUInt8())
        }
        //
        data = commandArr.toDataWithCRC()
    }
}

struct ResponseWriteRulesOfSoundPackageMode: CommandResponse {
    var soundPackage: SoundPackageModel
    var rulesCount: Int
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 6 {
            //
            let sound = SoundModel(id: arrUInt16[1], versionID: arrUInt16[2])
            soundPackage = SoundPackageModel(sound: sound, modeID: arrUInt16[3])
            rulesCount = Int(arrUInt16[4])
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

//MARK: - 5
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

//MARK: - 6
/// 6 - Прослушивание тестового сэмпла звукового пакета на устройстве
struct StartPlaySound: CommandProtocol {
    var u16Command: CommandsU16 = .startPlaySample
    var data: Data
    
    init(sound: SoundModel) {
        var commandArr = u16Command.arrU8
        //
        commandArr.append(sound.id.convertToUInt8())
        commandArr.append(sound.id.convertToUInt8())
        //
        data = commandArr.toDataWithCRC()
        print("Start Play sound: \(data.convertToHEX()))")
    }
}

struct ResponseStartPlaySound: CommandResponse {
    var soundID: UInt16
    var versionOfPackageID: UInt16
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 4 {
            //
            soundID = arrUInt16[1]
            versionOfPackageID = arrUInt16[2]
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

struct StopListenSample: CommandProtocol {
    var u16Command: CommandsU16 = .stopListenSample
    var data = CommandsU16.stopListenSample.arrU8.toDataWithCRC()
}

struct ResponseStopListenSample: CommandResponse {
    init(from data: Data) {
        parseData(data)
    }
}

//MARK: - 8
/// 8 - Чтение ID установленных звуковых пакетов
struct ReadIDSounds: CommandProtocol {
    var u16Command: CommandsU16 = .readIDSounds
    let data = CommandsU16.readIDSounds.arrU8.toDataWithCRC()
}

struct ResponseReadIDSounds: CommandResponse {
    var packageCount: Int
    var soundPackages: [SoundPackageModel]
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count >= 5 {
            packageCount = Int(arrUInt16[1])
            soundPackages = []
            
            // array of all presets info (1 preset == 3 elements of array)
            var packageArr = arrUInt16.subArray(fromIndex: 3, toIndex: arrUInt16.count-1)
            
            if packageArr.count % 3 == 0 {
                while packageArr.count != 0 {
                    soundPackages.append(SoundPackageModel(sound: SoundModel(id: packageArr[0], versionID:  packageArr[1]), modeID: packageArr[2]))
                    packageArr.removeFirst(3)
                }
            }
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

//MARK: - 9
/// 9 - Чтение пресетов
struct ReadPresets: CommandProtocol {
    var u16Command: CommandsU16 = .readPresets
    let data = CommandsU16.readPresets.arrU8.toDataWithCRC()
}

struct ResponseReadPresets: CommandResponse {
    var presetID: UInt16
    var presetCount: Int
    var presets: [PresetModel] = []
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count >= 7 {
            presetID = arrUInt16[1]
            presetCount = Int(arrUInt16[2])
            
            // array of all presets info (1 preset == 3 elements of array)
            var arrayOfPresets = arrUInt16.subArray(fromIndex: 3, toIndex: arrUInt16.count-1)
            
            if arrayOfPresets.count % 3 == 0 {
                while arrayOfPresets.count != 0 {
                    presets.append(PresetModel(soundPackageID: arrayOfPresets[0], modeID: arrayOfPresets[1], activity: arrayOfPresets[2]))
                    arrayOfPresets.removeFirst(3)
                }
            }
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

//MARK: - 10 
/// 10 - Запись Пресетoв
struct WritePresets: CommandProtocol {
    var u16Command: CommandsU16 = .writePresets
    var data: Data
    
    init(currentPresetID: UInt16, presetsArr: [PresetModel]) {
        var commandArr = u16Command.arrU8
        //
        commandArr.append(currentPresetID.convertToUInt8())
        commandArr.append(presetsArr.count.convertToUInt8())
        //
        for preset in presetsArr {
            commandArr.append(preset.soundPackageID.convertToUInt8())
            commandArr.append(preset.modeID.convertToUInt8())
            commandArr.append(preset.activity.convertToUInt8())
        }
        //
        data = commandArr.toDataWithCRC()
        print("Write presets: \(data.convertToHEX()))")
    }
}

struct ResponseWritePresets: CommandResponse {
    init(from data: Data) {
        parseData(data)
    }
}

//MARK: - 11
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
    var presetID: UInt16
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 3 {
            presetID = arrUInt16[1]
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

//MARK: - 12
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

//MARK: - 13
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

//MARK: - 14
/// 14 - Reading ID and version parameters of CAN from peripheral
struct ReadCAN: CommandProtocol {
    var u16Command: CommandsU16 = .readCAN
    let data = CommandsU16.readCAN.arrU8.toDataWithCRC()
}

struct ResponseReadCAN: CommandResponse {
    var can: CAN_Model
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 4 {
            //
            can = CAN_Model(id: arrUInt16[1], versionID: arrUInt16[2])
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

//MARK: - 15
/// 15 - Writing parameters of CAN to peripheral
struct WriteCAN: CommandProtocol {
    var u16Command: CommandsU16 = .writeCAN
    var data: Data
    
    init(CAN: CAN_Model, paramID: UInt16, rules: [RuleModel]) {
        var commandArr = u16Command.arrU8
        //
        commandArr.append(CAN.id.convertToUInt8())
        commandArr.append(CAN.versionID.convertToUInt8())
        commandArr.append(paramID.convertToUInt8())
        commandArr.append(rules.count.convertToUInt8())
        //
        for rule in rules {
            commandArr.append(rule.id.convertToUInt8())
            commandArr.append(rule.means.convertToUInt8())
        }
        //
        data = commandArr.toDataWithCRC()
    }
}

struct ResponseWriteCAN: CommandResponse {
    var can: CAN_Model
    var rulesCount: Int
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 5 {
            //
            can = CAN_Model(id: arrUInt16[1], versionID: arrUInt16[2])
            rulesCount = Int(arrUInt16[3])
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
        }
    }
}

//MARK: - 16
/// 16 - Команда пойлинга
struct Poyling: CommandProtocol {
    var u16Command: CommandsU16 = .poyling
    let data = CommandsU16.poyling.arrU8.toDataWithCRC()
}

struct ResponsePoyling: CommandResponse {
    var state: PeripheralState
    var percent: UInt16
    
    init(from data: Data) throws {
        let val = [UInt8](data)
        if let arrUInt16 = val.convertToArrUInt16(),
            arrUInt16.count == 4 {
            //
            let byte2 = arrUInt16[1]
            state = PeripheralState(rawValue: byte2)
            percent = arrUInt16[2]
            //
            parseData(data)
        } else {
            throw RequestError.parsingError
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
