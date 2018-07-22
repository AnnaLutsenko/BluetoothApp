//
//  ResponseCreator.swift
//  TestBluetoothApp
//
//  Created by Anna on 19.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation

struct ResponseFactory: ResponseCreator {
    static let errorCode = UInt8(0x80)
    
}

protocol ResponseCreator {
    static func getCommandResponse(_ data: Data) -> CommandResponse
}

extension ResponseCreator {
    
    static func getCommandResponse(_ data: Data) -> CommandResponse {
        let command = Array([UInt8](data).prefix(2))
        let commandSecondByte = command[1]
        
        switch commandSecondByte {
        case CommandsU16.readParameters.secondByte:
            return ResponseReadParameters(from: data)
        case CommandsU16.deleteSound.secondByte:
            return ResponseDeleteSound(from: data)
        case CommandsU16.startPlaySample.secondByte:
            return ResponseStartPlaySound(from: data)
        case CommandsU16.readPresets.secondByte:
            return ResponseReadPresets(from: data)
        case CommandsU16.selectPreset.secondByte:
            return ResponseSelectCurrentPreset(from: data)
        case CommandsU16.readIDSounds.secondByte:
            return ResponseReadIDSounds(from: data)
        case CommandsU16.muteON.secondByte:
            return ResponseMuteOn(from: data)
        case CommandsU16.muteOFF.secondByte:
            return ResponseMuteOff(from: data)
        case CommandsU16.readCAN.secondByte:
            return ResponseReadCAN(from: data)
        case CommandsU16.poyling.secondByte:
            return ResponsePoyling(from: data)
        default:
            return ResponseDefault(from: data)
        }
    }
}
