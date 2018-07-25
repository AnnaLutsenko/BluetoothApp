//
//  BLERequestManager.swift
//  TestBluetoothApp
//
//  Created by Anna on 7/21/18.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation

class BLERequestManager {
    private unowned let peripheralManager: PeripheralManager
    
    /// Manager for updating firmware on peripheral
    private let firmwareManager = FirmwareManager()
    
    private (set) var peripheralModel: PeripheralModel?
    private (set) var firmwareData: Data?
    
    init(peripheralManager: PeripheralManager) {
        self.peripheralManager = peripheralManager
    }
    
    // MARK: - Firmware
    func getNewFirmware(success: @escaping FirmwareManager.Success, failure: @escaping FirmwareManager.Failure) {
        
        firmwareManager.getFirmware(success: { data in
            print("Successfull getting firmware!")
            self.firmwareData = data
            success(data)
        }, failure: failure)
    }
    
    func updateFirmware(version: VersionModel, block: BlockModel, FW: [UInt8], success: @escaping ()-> Void, failure: @escaping FirmwareManager.Failure) {
        
        let command = UpdateFirmware(version: version, block: block, FW: FW)
        
        peripheralManager.updateFW(command: command, success: {
            success()
        }, failure: failure)
    }
    
    func confirmationUpdate(device: DeviceType, version: VersionModel, success: @escaping ((ResponseConfirmationUpdate) -> Void), failure: @escaping FirmwareManager.Failure) {
        
        peripheralManager.run(command: ConfirmationUpdate(device: device, version: version), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseConfirmationUpdate else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func selectCurrentPreset(id: UInt16, success: @escaping ((ResponseSelectCurrentPreset) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: SelectCurrentPreset(presetID: id), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseSelectCurrentPreset else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func deleteSound(id: UInt16, success: @escaping ((ResponseDeleteSound) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: DeleteSound(soundID: id), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseDeleteSound else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func startPlaySound(sound: SoundModel, success: @escaping ((ResponseStartPlaySound) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: StartPlaySound(sound: sound), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseStartPlaySound else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func stopListenSample( success: @escaping ((ResponseStopListenSample) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: StopListenSample(), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseStopListenSample else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func readPresets(completion: @escaping ((ResponseReadPresets) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: ReadPresets(), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseReadPresets else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            completion(resp)
        }, failure: failure)
    }
    
    func writePresets(presetID: UInt16, presetsArr: [PresetModel], success: @escaping ((ResponseWritePresets) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: WritePresets(currentPresetID: presetID, presetsArr: presetsArr), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseWritePresets else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func readIDSounds(completion: @escaping ((ResponseReadIDSounds) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: ReadIDSounds(), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseReadIDSounds else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            completion(resp)
        }, failure: failure)
    }
    
    func readParameters(success: @escaping ((ResponseReadParameters)-> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: ReadParameters(), success: { (commandResponse) in
            
            guard let resp = commandResponse as? ResponseReadParameters else {
                failure(RequestError.unexpectedResponse)
                return
            }
            self.peripheralModel = resp.peripheral
            success(resp)
            
        }) { (error) in
            failure(error)
        }
    }
    
    func readCAN(completion: @escaping ((ResponseReadCAN) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: ReadCAN(), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseReadCAN else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            completion(resp)
        }, failure: failure)
    }
    
    func writeCAN(_ can: CAN_Model, paramID: UInt16, rules: [RuleModel], success: @escaping ((ResponseWriteCAN) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: WriteCAN(CAN: can, paramID: paramID, rules: rules), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseWriteCAN else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func writeRulesOfSample(sample: SampleModel, rules: [RuleModel], success: @escaping ((ResponseWriteRulesOfSample) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: WriteRulesOfSample(sample: sample, rules: rules), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseWriteRulesOfSample else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func writeRulesOfSoundPackageMode(soundPackage: SoundPackageModel, rules: [RuleModel], success: @escaping ((ResponseWriteRulesOfSoundPackageMode) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: WriteRulesOfSoundPackageMode(soundPackage: soundPackage, rules: rules), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseWriteRulesOfSoundPackageMode else {
                failure(RequestError.unexpectedResponse)
                return
            }
            
            success(resp)
        }, failure: failure)
    }
    
    func muteON(success: @escaping ((ResponseMuteOn)-> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: MuteOn(), success: { (commandResponse) in
            
            guard let resp = commandResponse as? ResponseMuteOn else {
                failure(RequestError.unexpectedResponse)
                return
            }
            success(resp)
            
        }, failure: failure)
    }
    
    func muteOFF(success: @escaping ((ResponseMuteOff)-> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: MuteOff(), success: { (commandResponse) in
            
            guard let resp = commandResponse as? ResponseMuteOff else {
                failure(RequestError.unexpectedResponse)
                return
            }
            success(resp)
            
        }, failure: failure)
    }
    
    func poyling(success: @escaping ((ResponsePoyling)-> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: Poyling(), success: { (commandResponse) in
            
            guard let resp = commandResponse as? ResponsePoyling else {
                failure(RequestError.unexpectedResponse)
                return
            }
            success(resp)
            
        }, failure: failure)
    }
}
