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
    @IBOutlet private weak var readDataLbl: UILabel!
    @IBOutlet private weak var peripheralNameLbl: UILabel!
    @IBOutlet private weak var writeDataTF: UITextField!
    
    /// Core Bluetooth
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    
    private var rssiReloadTimer: Timer?
    private var services: [CBService] = []
    
    //
    var arrayReadWriteChar = [CBCharacteristic]()
    //
    
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
    
    //MARK: Actions
    @IBAction func writeValue() {
        writeDataTF.resignFirstResponder()
        
//        guard let text = writeDataTF.text,
//            let data = text.data(using: .utf8) else { return }
        
        if peripheral.state == .connected {
            
            //write a value to the characteristic
            
            let nsData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00], length: 6)
            let data = nsData as Data
            
            peripheral.writeValue(data,  for: arrayReadWriteChar[0], type: .withoutResponse)
            
        } else {
            print("Not connected")
        }
    }
}

extension PeripheralConnectedViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("did Write ValueFor", characteristic)
        
        if let err = error {
            print(err.localizedDescription)
        }
        
        if let rxData = characteristic.value {
            
            let numberOfBytes = rxData.count
            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
            (rxData as NSData).getBytes(&rxByteArray, length: numberOfBytes)
            print(rxByteArray)
            
            let value = [UInt8](rxData)
            print(value)    //whole array
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
            print(rxByteArray)
            
            let val = [UInt8](value)
            print(val)
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
                peripheral.readValue(for: characteristic)
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
        peripheral.readValue(for: characteristic)
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
