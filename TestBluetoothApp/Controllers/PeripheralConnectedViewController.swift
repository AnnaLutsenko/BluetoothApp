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
//        peripheralManager?.getNewFirmware()
    }
    
    @objc private func refreshRSSI(){
        peripheralManager?.peripheral.readRSSI()
    }
    
    func isDeviceConnected() -> Bool {
        return (peripheral.state == .connected)
    }
    
    //MARK: Actions
    @IBAction func downloadFirmware(_ sender: UIButton) {
        
        peripheralManager?.bleRequestManager.getNewFirmware(success: { (data) in
            debugPrint("New firmware was download: \(data)")
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func updateFirmware(_ sender: UIButton) {
        
        guard let data = peripheralManager?.bleRequestManager.firmwareData else {
            return
        }
        let version = VersionModel(firmware: UInt16(1), hardware: UInt16(1))
        var dataInU8 = [UInt8](data)
        var arrOfBlock: [[UInt8]] = []
        
        while !dataInU8.isEmpty {
            let n = dataInU8.count >= 256 ? 256 : dataInU8.count
            //
            let block = Array(dataInU8.prefix(n))
            arrOfBlock.append(block)
            dataInU8.removeFirst(n)
        }
        
        let myDispatchGroup = DispatchGroup()
        for blockFW in arrOfBlock.enumerated() {
            myDispatchGroup.enter()
            let blockSent = BlockModel(count: UInt16(arrOfBlock.count), currentNumber: UInt16(blockFW.offset + 1))
            print(blockSent)
            peripheralManager?.bleRequestManager.updateFirmware(version: version, block: blockSent, FW: blockFW.element, success: {
                print("Sent block \(blockFW.offset)")
                //
                myDispatchGroup.leave()
                
            }, failure: { (error) in
                print(error.localizedDescription)
                myDispatchGroup.leave()
            })
        }
        
        myDispatchGroup.notify(queue: .main) {
            debugPrint("Finished all requests.")
        }
        
    }
    
    @IBAction func confirmationUpdate(_ sender: UIButton) {
        peripheralManager?.bleRequestManager.confirmationUpdate(device: .main, version: VersionModel(firmware: UInt16(1), hardware: UInt16(1)), success: { (resp) in
            debugPrint("---- Success confirmation Update ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func readIDSound() {
        
        peripheralManager?.bleRequestManager.readIDSounds(completion: { (resp) in
            debugPrint("---- Success Read ID Sounds ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func deleteSound() {
        
        peripheralManager?.bleRequestManager.deleteSound(id: UInt16(8), success: { (resp) in
            debugPrint("---- Success Delete Sounds ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    
    @IBAction func startPlaySound() {
        let sound = SoundModel(id: UInt16(8), versionID: UInt16(44))
        //
        peripheralManager?.bleRequestManager.startPlaySound(sound: sound, success: { (resp) in
            debugPrint("---- Success start playing sound ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func stopPlaySound() {
        
        peripheralManager?.bleRequestManager.stopListenSample(success: { (resp) in
            debugPrint("---- Success stop listen sample ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func selectPresets(_ sender: UIButton) {
        peripheralManager?.bleRequestManager.selectCurrentPreset(id: UInt16(8), success: { (resp) in
            debugPrint("---- Success select presets ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error)
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
    
    @IBAction func writePresets(_ sender: UIButton) {
        let preset = PresetModel(soundPackageID: UInt16(21), modeID: UInt16(45), activity:  UInt16(22))
        peripheralManager?.bleRequestManager.writePresets(presetID: UInt16(8), presetsArr: [preset], success: { (resp) in
            debugPrint("---- Success write Presets ----")
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
    
    @IBAction func writeCAN(_ sender: UIButton) {
        let can = CAN_Model(id: UInt16(0), versionID: UInt16(0))
        let param: UInt16 = 0x0000
        let rules = [RuleModel(id: UInt16(0x0003), means: UInt16(1))]
        //
        peripheralManager?.bleRequestManager.writeCAN(can, paramID: param, rules: rules, success: { (resp) in
            debugPrint("---- Successful Write CAN ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func writeRulesOfSample(_ sender: UIButton) {
        //
        let sound = SoundModel(id: UInt16(0), versionID: UInt16(0))
        let sample = SampleModel(sound: sound, id: UInt16(3))
        let rules = [RuleModel(id: UInt16(0x0007), means: UInt16(50))]
        //
        peripheralManager?.bleRequestManager.writeRulesOfSample(sample: sample, rules: rules, success: { (resp) in
            debugPrint("---- Successful writeRulesOf Sample ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func writeRulesOfSoundPackageMode(_ sender: UIButton) {
        //
        let sound = SoundModel(id: UInt16(0), versionID: UInt16(0))
        let soundPack = SoundPackageModel(sound: sound, modeID: UInt16(3))
        let rules = [RuleModel(id: UInt16(0x0000), means: UInt16(50))]
        //
        peripheralManager?.bleRequestManager.writeRulesOfSoundPackageMode(soundPackage: soundPack, rules: rules, success: { (resp) in
            debugPrint("---- Successful writeRulesOfSoundPackageMode ----")
            debugPrint(resp)
        }, failure: { (error) in
            debugPrint(error.localizedDescription)
        })
    }
    
    @IBAction func poyling(_ sender: UIButton) {
        peripheralManager?.bleRequestManager.poyling(success: { (resp) in
            debugPrint("---- Successful Poyling ----")
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
