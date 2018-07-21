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
    var peripheralManager: PeripheralManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initController()
    }
    
    func initController() {
        peripheralNameLbl.text = peripheral.name
        //        rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshRSSI), userInfo: nil, repeats: true)
        //
        peripheralManager?.getNewFirmware()
    }
    
    @objc private func refreshRSSI(){
        peripheralManager?.peripheral.readRSSI()
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
    @IBAction func readIDSound() {
        
        peripheralManager?.bleRequestManager.readIDSounds(completion: { (resp) in
            debugPrint("---- Success Read ID Sounds ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func readPresets(_ sender: UIButton) {
        peripheralManager?.bleRequestManager.readPresets(completion: { (resp) in
            debugPrint("---- Success read Presets ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error)
        })
    }
    
    @IBAction func readParameters(_ sender: UIButton) {
        peripheralManager?.bleRequestManager.readParameters(success: { (resp) in
            debugPrint("---- Succes read Parameters ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error)
        })
    }
    
    @IBAction func muteON(_ sender: UIButton) {
        
        peripheralManager?.bleRequestManager.muteON(success: { (resp) in
            debugPrint("---- Success mute ON -----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func muteOFF(_ sender: UIButton) {
        
        peripheralManager?.bleRequestManager.muteOFF(success: { (resp) in
            debugPrint("---- Success mute OFF -----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func readCAN(_ sender: UIButton) {
        
        peripheralManager?.bleRequestManager.readCAN(completion: { (resp) in
            debugPrint("---- Successful Read CAN ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
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
