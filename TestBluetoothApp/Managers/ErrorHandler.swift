//
//  ErrorHandler.swift
//  TestBluetoothApp
//
//  Created by Anna on 12.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation


enum RequestError: Error {
    case wrongData
    case unexpectedResponse
    case dataNotComplete
    case parsingError
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .wrongData:
            return "Server returned wrong data. Try later please"
        default:
            return "Ops! Something went wrong. Could you try later."
        }
    }
}

enum PeripheralError: UInt16, Error {
    
    case firmwareNotInstalled       = 0x8051 // 3
    case soundNotWriting            = 0x8040 // 4.1
    case rulesOfSoundNotWriting     = 0x0042 // 4.3
    case rulesOfSampleNotWriting    = 0x8043 // 4.4
    case deviceIsNotReady           = 0x8044 // 4.5
    
    case audioIsNotInstalled        = 0x8046 // 5
    case sampleIsNotInDevice        = 0x8020 // 6
    case sampleIsNotPlayed          = 0x8021 // 6
    case soundPackageNotInstalled   = 0x8047 // 8
    case presetsIsNotInstalled      = 0x8031 // 9
    
    case presetNotWriting           = 0x8030 // 10
    case presetNotInstalled         = 0x8045 // 11
    case alreadyInMute              = 0x8048 // 12
    case notInMute                  = 0x8049 // 13
    
    case readOfCANFailed            = 0x804A // 14
    case deviceCanNotSetParameters  = 0x804B // 15
    
    static func error(with code: UInt16) -> Error {
        return PeripheralError(rawValue: code) ?? RequestError.unexpectedResponse
    }
    
    var localizedDescription: String {
        switch self {
        case .firmwareNotInstalled:
            return "The integrity of the firmware has been broken or updated for some other reason is impossible"
        case .soundNotWriting:
            return "The device is not ready to receive a sound package."
        case .rulesOfSoundNotWriting:
            return "The device is not ready to record the rules of the audio sample."
        case .rulesOfSampleNotWriting:
            return "The device is not ready to record audio packet mode rules."
        case .deviceIsNotReady:
            return "The device can not execute the command."
        case .audioIsNotInstalled:
            return "The audio package is not installed on the device."
        case .sampleIsNotInDevice:
            return "The test sound sample is not in the device."
        case .sampleIsNotPlayed:
            return "The test sound sample at the time of receiving the command is not played by the device."
        case .soundPackageNotInstalled:
            return "The device doesn't have installed sound packages."
        case .presetsIsNotInstalled:
            return "The device doesn't have installed presets."
        case .presetNotWriting:
            return "The device can not record the preset."
        case .presetNotInstalled:
            return "Preset not installed on device"
        case .alreadyInMute:
            return "The device can not execute the command (already in MUTE)"
        case .notInMute:
            return "The device can not execute a command (not in MUTE)"
        case .readOfCANFailed:
            return "The CAN configuration on the device failed"
        case .deviceCanNotSetParameters:
            return "The device can not set CAN parameters"
        }
    }
}
