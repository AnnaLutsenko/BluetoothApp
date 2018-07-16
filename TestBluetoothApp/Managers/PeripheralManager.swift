//
//  PeripheralManager.swift
//  TestBluetoothApp
//
//  Created by Anna on 14.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLERequest {
    typealias Success = (CommandResponse)->()
    typealias Failure = (Error)->()
    //
    var command: CommandProtocol
    var success: Success
    var failure: Failure
    
    init(command: CommandProtocol, success: @escaping Success, failure: @escaping Failure) {
        self.command = command
        self.success = success
        self.failure = failure
    }
    
    func isThisCommand(_ data: Data) -> Bool {
//        command.data first 2 byte and compare by second byte
        //TODO: check data
        
        return true
    }
    
    func isDataFully(_ data: Data) -> Bool {
        let bytes = [UInt8](data)
        //
        let previousByte = bytes[bytes.count-2]
        let lastByte = bytes[bytes.count-1]
        
        let hexValCRC16 = CRC16.bytesConvertToHexString([previousByte, lastByte])
        //
        let data = Array(bytes.prefix(bytes.count-2)) // data without CRC16
        guard let modbusValue = CRC16.crc16(data, type: .MODBUS) else { return false } // get CRC16 from data
        //
        let modbusStr = String(format: "%4X", modbusValue)
        print("MODBUS = \(modbusStr)")
        print("CRC16 = \(hexValCRC16)")
        //
        return hexValCRC16 == modbusStr
    }
}

class PeripheralManager: NSObject {
    let peripheral: CBPeripheral
    //
    private var arrayReadWriteChar: [CBCharacteristic] = []
    private var bleRequests: [BLERequest] = []
    
    
    init(with peripheral: CBPeripheral) {
        self.peripheral = peripheral
        //
        super.init()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    //MARK: - Metonds
    func run(command: CommandProtocol, success: @escaping BLERequest.Success, failure: @escaping BLERequest.Failure) {
        
        bleRequests.append(BLERequest(command: command, success: success, failure: failure))
        peripheral.writeValue(command.data, for: arrayReadWriteChar[0], type: .withoutResponse)
    }
}

// MARK: - CBPeripheralDelegate Methods
extension PeripheralManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
        guard let services = peripheral.services else { return }
        
        for serv in services {
            peripheral.discoverCharacteristics(nil, for: serv)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let error = error {
            print("Error connecting peripheral: \(error.localizedDescription)")
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
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let value = characteristic.value {
            let numberOfBytes = value.count
            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
            (value as NSData).getBytes(&rxByteArray, length: numberOfBytes)
            
            print("-------------------")
            print("Data = \(value); \(value.count)")
            print("Bytes array = \(rxByteArray)")
            
            let request = bleRequests.first(where: {$0.isThisCommand(value)})
            // read first 2 bytes (fabric method)
            // getResponseWithData
            let response = ResponseReadParameters(from: value)
            request?.success(response)
            bleRequests = bleRequests.filter { $0 !== request }
            
            // Handle errors
            //
            
//            parseData(value)
            
            let val = [UInt8](value)
            
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
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("did Write ValueFor", characteristic)
        
        if let err = error {
            print(err.localizedDescription)
        }
        
        if let data = characteristic.value {
            let value = [UInt8](data)
            print("did Write Value: \(value)")    //whole array
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        debugPrint(RSSI)
    }
    
}