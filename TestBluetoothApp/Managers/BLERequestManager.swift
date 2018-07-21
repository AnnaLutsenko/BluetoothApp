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
    
    init(peripheralManager: PeripheralManager) {
        self.peripheralManager = peripheralManager
    }
    
    func readPresets(completion: @escaping ((ResponseReadPresets) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: ReadPresets(), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseReadPresets else {
                failure(PeripheralError.unknownError)
                return
            }
            
            completion(resp)
        }, failure: failure)
    }
    
    func readIDSounds(completion: @escaping ((ResponseReadIDSounds) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: ReadIDSounds(), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseReadIDSounds else {
                failure(PeripheralError.unknownError)
                return
            }
            
            completion(resp)
        }, failure: failure)
    }
    
    func readParameters(success: @escaping ((ResponseReadParameters)-> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: ReadParameters(), success: { (commandResponse) in
            
            guard let resp = commandResponse as? ResponseReadParameters else {
                failure(PeripheralError.unknownError)
                return
            }
            success(resp)
            
        }) { (error) in
            failure(error)
        }
    }
    
    func readCAN(completion: @escaping ((ResponseReadCAN) -> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: ReadCAN(), success: { (commandResponse) in
            guard let resp = commandResponse as? ResponseReadCAN else {
                // TODO: Throw error or failure()
                failure(PeripheralError.unknownError)
                return
            }
            
            completion(resp)
        }, failure: failure)
    }
    
    func muteON(success: @escaping ((ResponseMuteOn)-> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: MuteOn(), success: { (commandResponse) in
            
            guard let resp = commandResponse as? ResponseMuteOn else {
                failure(PeripheralError.unknownError)
                return
            }
            success(resp)
            
        }, failure: failure)
    }
    
    func muteOFF(success: @escaping ((ResponseMuteOff)-> Void), failure: @escaping BLERequest.Failure) {
        
        peripheralManager.run(command: MuteOff(), success: { (commandResponse) in
            
            guard let resp = commandResponse as? ResponseMuteOff else {
                failure(PeripheralError.unknownError)
                return
            }
            success(resp)
            
        }, failure: failure)
    }
}
