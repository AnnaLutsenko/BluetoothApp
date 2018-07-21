//
//  PeripheralManager.swift
//  TestBluetoothApp
//
//  Created by Anna on 14.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation
import CoreBluetooth

enum PeripheralState: UInt16 {
    case free = 0x0000
    case busy = 0x0001
    case error = 0x0002
    case unknownError
    
    init(rawValue: UInt16) {
        switch rawValue {
        case PeripheralState.free.rawValue: self = .free
        case PeripheralState.busy.rawValue: self = .busy
        case PeripheralState.error.rawValue: self = .error
        default: self = .unknownError
        }
    }
}

class PeripheralManager: NSObject {
    
    let peripheral: CBPeripheral
    //
    /// Manager for updating firmware on peripheral
    let firmwareManager = FirmwareManager()
    //
    private var arrayReadWriteChar: [CBCharacteristic] = []
    private var bleRequests: [BLERequest] = []
    
    private (set) var bleRequestManager: BLERequestManager!
    
    init(with peripheral: CBPeripheral) {
        self.peripheral = peripheral
        //
        super.init()
        self.bleRequestManager = BLERequestManager(peripheralManager: self)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    //MARK: - Metonds
    func run(command: CommandProtocol, success: @escaping BLERequest.Success, failure: @escaping BLERequest.Failure) {
        
        bleRequests.append(BLERequest(command: command, success: success, failure: failure))
        peripheral.writeValue(command.data, for: arrayReadWriteChar[0], type: .withoutResponse)
    }
    
    func getNewFirmware() {
        firmwareManager.getFirmware(success: { _ in
            print("Successfull getting firmware!")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

// MARK: - CBPeripheralDelegate Methods
extension PeripheralManager: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let value = characteristic.value {
            let numberOfBytes = value.count
            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
            (value as NSData).getBytes(&rxByteArray, length: numberOfBytes)
            
            debugPrint("-------------------")
            debugPrint("Data = \(value); \(value.count)")
            
            
            guard let request = bleRequests.first(where: {$0.isThisCommand(value)}) else {
                return
            }
            
            let command = Array([UInt8](value).prefix(2))
            
            if !request.isDataFull(value)
            {
                debugPrint("Data is not full!")
                request.failure(PeripheralError.dataNotComplete)
            }
            else if command[0] == ResponseFactory.errorCode
            {
                let u16 = CRC16.bytesConvertToInt16(command)
                debugPrint("ERROR -----> \(PeripheralError.init(rawValue: u16))")
                request.failure(PeripheralError.init(rawValue: u16))
            }
            else
            {
                let response = ResponseFactory.getCommandResponse(value)
                request.success(response)
            }
            
            bleRequests = bleRequests.filter { $0 !== request }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
        guard let services = peripheral.services else { return }
        
        for serv in services {
            peripheral.discoverCharacteristics(nil, for: serv)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            print("Error discovering service characteristics: \(error.localizedDescription)")
        }
        
        // PRINT characteristic's properties and descriptors
        service.characteristics?.forEach({ characteristic in
            if let descriptors = characteristic.descriptors {
                print(descriptors)
            }
            print(characteristic.properties)
        })
        //
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("characteristic uuid found: \(characteristic.uuid)")
                //
                peripheral.setNotifyValue(true, for: characteristic)
                arrayReadWriteChar.append(characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
    }
}
