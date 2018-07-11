//
//  PeripheralConnectedViewController.swift
//  TestBluetoothApp
//
//  Created by Anna on 20.06.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralConnectedViewController: UIViewController, StoryboardInstance {
    
    /// UI Elements
    @IBOutlet private weak var rssiLbl: UILabel!
    @IBOutlet private weak var peripheralNameLbl: UILabel!
    
    /// Core Bluetooth
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    
    private var rssiReloadTimer: Timer?
    private var services: [CBService] = []
    
    //
    var arrayReadWriteChar = [CBCharacteristic]()
    //
    let CRC = CRC16.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initController()
    }
    
    func initController() {
        peripheralNameLbl.text = peripheral.name
        //
        peripheral.delegate = self
        centralManager?.connect(peripheral, options: nil)
        //
        rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshRSSI), userInfo: nil, repeats: true)
    }
    
    func storyboardInstance() {
        
    }
    
    @objc private func refreshRSSI(){
        peripheral.readRSSI()
    }
    
    func isDeviceConnected() -> Bool {
        return (peripheral.state == .connected)
    }
    
    /// Чтение параметров устройства (2)
    func readParametersOfDevice() {
        let data = [UInt8]([0x00, 0x01])
        writeValueToPeripheral(data)
    }
    
    /// Чтение пресетов (9)
    func readPersets() {
        let data = [UInt8]([0x00, 0x31])
        writeValueToPeripheral(data)
    }
    
    func readIDSounds() {
        let data = [UInt8]([0x00, 0x47])
        writeValueToPeripheral(data)
    }
    
    func writeValueToPeripheral(_ val: [UInt8]) {
        let dataInCRC16 = CRC.crc16(val, type: .MODBUS)
        
        if dataInCRC16 != nil {
            let modbusStr = String(format: "0x%4X", dataInCRC16!)
            print("MODBUS = " + modbusStr)
        }
        guard let crc16InUInt8 = dataInCRC16?.convertToUInt8() else {return}
        //
        let dataToSend = [val[0], val[1], crc16InUInt8[0], crc16InUInt8[1]]
        let nsData = NSData(bytes: dataToSend, length: dataToSend.count) as Data
        //
        peripheral.writeValue(nsData,  for: arrayReadWriteChar[0], type: .withoutResponse)
    }
    
    //MARK: Actions
    @IBAction func writeValue() {
        readIDSounds()
    }
    
    @IBAction func readPresets(_ sender: UIButton) {
        if isDeviceConnected() {
            readPersets()
        } else {
            print("Not connected")
        }
    }
    
    @IBAction func readParameters(_ sender: UIButton) {
        if isDeviceConnected() {
            readParametersOfDevice()
        } else {
            print("Not connected")
        }
    }
    
    func isDataFully(_ data: Data) -> Bool {
        let bytes = [UInt8](data)
        //
        let previousByte = bytes[bytes.count-2]
        let lastByte = bytes[bytes.count-1]
        
        let hexValCRC16 = CRC.bytesConvertToHexString([previousByte, lastByte])
        //
        let data = Array(bytes.prefix(bytes.count-2)) // data without CRC16
        guard let modbusValue = CRC.crc16(data, type: .MODBUS) else { return false } // get CRC16 from data
        //
        let modbusStr = String(format: "%4X", modbusValue)
        print("MODBUS = \(modbusStr)")
        print("CRC16 = \(hexValCRC16)")
        //
        return hexValCRC16 == modbusStr
    }
    
    func parseData(_ data: Data) {
        isDataFully(data) ? print("CRC are equal") : print("Data is not full")
        
        //get a data object from the CBCharacteristic
        let bytesNum : [UInt8] = [data[2], data[3]] // little-endian LSB -> MSB
        let u16 = CRC.bytesConvertToInt16(bytesNum)
        print("u16 = \(u16)")
        
        // READ Value
        let bytes = [UInt8](data)
        print("Data in HEX: \(CRC.bytesConvertToHexString(bytes))")
        //
        let bytesWithoutCRC = Array(bytes.prefix(bytes.count-2)) // data without CRC16
    }
}

extension PeripheralConnectedViewController: CBPeripheralDelegate {
    
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
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let err = error {
            print(err.localizedDescription)
        }
        
        if let value = characteristic.value {
            
            let numberOfBytes = value.count
            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
            (value as NSData).getBytes(&rxByteArray, length: numberOfBytes)
            print("-------------------")
            print("Data = \(value); \(value.count)")
            print("Bytes array = \(rxByteArray)")
            
            
            parseData(value)
            //
            let val = [UInt8](value)
            
            if val.count >= 10 {
                //
                let hexValCommand = CRC.bytesConvertToHexString([val[0], val[1]])
                let hexValueNumber = CRC.bytesConvertToHexString([val[2], val[3]])
                let hexValVersionFW = CRC.bytesConvertToInt16([val[4], val[5]])
                let hexValVersionHW = CRC.bytesConvertToInt16([val[6], val[7]])
                let hexValCRC16 = CRC.bytesConvertToHexString([val[8], val[9]])
                //
                print("HEX command = \(hexValCommand)")
                print("HEX serial number = \(hexValueNumber)")
                print("u16 version FW = \(hexValVersionFW)")
                print("u16 version HW = \(hexValVersionHW)")
                print("HEX CRC16= \(hexValCRC16)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
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
//        peripheral.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        switch RSSI.intValue {
        case -90 ... -60:
            rssiLbl.textColor = .btOrange
            break
        case -200 ... -90:
            rssiLbl.textColor = .btRed
            break
        default:
            rssiLbl.textColor = .btGreen
        }
        
        rssiLbl.text = "\(RSSI) dB"
    }
}
