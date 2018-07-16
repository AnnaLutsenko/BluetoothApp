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
    let firmwareManager = FirmwareManager()
    //
    var peripheralManager: PeripheralManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initController()
    }
    
    func initController() {
        peripheralNameLbl.text = peripheral.name
        //
        centralManager?.connect(peripheral, options: nil)
        //
//        rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshRSSI), userInfo: nil, repeats: true)
        //
        getNewFirmware()
        peripheral.discoverServices(nil)
    }
    /*
    @objc private func refreshRSSI(){
        peripheral.readRSSI()
    }
    */
    func getNewFirmware() {
        firmwareManager.getFirmware(success: { _ in
            print("Successfull getting firmware!")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func isDeviceConnected() -> Bool {
        return (peripheral.state == .connected)
    }
    
    
    func writeValueToPeripheral(_ val: [UInt8]) {
        let dataInCRC16 = CRC16.crc16(val, type: .MODBUS)
        
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
//        peripheralManager?.run(comand: ReadIDSounds(), success: <#BLERequest.Success#>, failure: <#BLERequest.Failure#>)
    }
    
    @IBAction func readPresets(_ sender: UIButton) {
        if isDeviceConnected() {
            peripheralManager?.run(command: ReadPresets(), success: { (resp) in
                print(resp)
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        } else {
            print("Not connected")
        }
    }
    
    @IBAction func readParameters(_ sender: UIButton) {
        if isDeviceConnected() {
//            readParametersOfDevice()
        } else {
            print("Not connected")
        }
    }
    
    
    
    func parseData(_ data: Data) {
//        isDataFully(data) ? print("CRC are equal") : print("Data is not full")
        
        //get a data object from the CBCharacteristic
        let bytesNum : [UInt8] = [data[2], data[3]] // little-endian LSB -> MSB
        let u16 = CRC16.bytesConvertToInt16(bytesNum)
        print("u16 = \(u16)")
        
        // READ Value
        let bytes = [UInt8](data)
        print("Data in HEX: \(CRC16.bytesConvertToHexString(bytes))")
        //
        let bytesWithoutCRC = Array(bytes.prefix(bytes.count-2)) // data without CRC16
    }
}

/*
extension PeripheralConnectedViewController: CBPeripheralDelegate {
    
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
*/
