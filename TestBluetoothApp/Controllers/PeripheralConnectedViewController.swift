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
//        rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshRSSI), userInfo: nil, repeats: true)
        //
        getNewFirmware()
    }
    
    @objc private func refreshRSSI(){
        peripheralManager?.peripheral.readRSSI()
    }
    
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
        peripheralManager?.run(command: ReadIDSounds(), success: { (resp) in
            print()
        }, failure: { (error) in
            print(error.localizedDescription)
        })

    }
    
    @IBAction func readPresets(_ sender: UIButton) {
        peripheralManager?.run(command: ReadPresets(), success: { (resp) in
            print()
        }, failure: { (error) in
            print(error.localizedDescription)
        })
    }
    
    @IBAction func readParameters(_ sender: UIButton) {
        peripheralManager?.run(command: ReadParameters(), success: { (resp) in
            print()
        }, failure: { (error) in
            print(error.localizedDescription)
        })
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
