//
//  PresetModel.swift
//  TestBluetoothApp
//
//  Created by Anna on 7/23/18.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation

struct PeripheralModel {
    var serialNumber: UInt16
    var version: VersionModel
}

struct VersionModel {
    var firmware: UInt16
    var hardware: UInt16
}

struct PresetModel {
    var soundPackageID: UInt16
    var modeID: UInt16
    var activity: UInt16
}

struct SoundModel {
    var id: UInt16
    var versionID: UInt16
}

struct SoundPackageModel {
    var sound: SoundModel
    var modeID: UInt16
}

struct SampleModel {
    var sound: SoundModel
    var id: UInt16
}

struct CAN_Model {
    var id: UInt16
    var versionID: UInt16
}

struct RuleModel {
    var id: UInt16
    var means: UInt16
}

struct BlockModel {
    var count: UInt16
    var currentNumber: UInt16
}
