//
//  PeripheralsViewController.swift
//  TestBluetoothApp
//
//  Created by Anna on 19.06.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralsViewController: UIViewController {

    /// UI Elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanBtn: ScanButton!
    
    /// Core Bluetooth
    private var centralManager: CBCentralManager?
    private var peripherals = Set<CBPeripheral>()
    //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initController()
    }
    
    func initController() {
        //Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        //
        scanBtn.setupDisabledState()
        scanBtn.style(with: .btBlue)
        scanBtn.update(isScanning: false)
        scanBtn.isEnabled = false
    }
    
    private func startScanning() {
        updateViewForScanning()
        peripherals = []
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        //stop scanning after 15 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.centralManager!.isScanning {
                strongSelf.centralManager?.stopScan()
                strongSelf.updateViewForStopScanning()
            }
        }
    }
    
    private func updateViewForScanning(){
        updateStatusText("Scanning BLE Devices...")
        scanBtn.update(isScanning: true)
    }
    
    private func updateViewForStopScanning(){
        let plural = peripherals.count > 1 ? "s" : ""
        updateStatusText("\(peripherals.count) Device\(plural) Found")
        scanBtn.update(isScanning: false)
    }
    
    private func updateStatusText(_ text: String) {
        title = text
    }
    
    //MARK: - Actions
    @IBAction private func scanBtnPressed(_ sender: AnyObject){
        if centralManager!.isScanning {
            centralManager?.stopScan()
            updateViewForStopScanning()
        }else{
            startScanning()
        }
    }
    
    //MARK: - Connect to peripheral
    func didTapConnect(peripheral: CBPeripheral) {
        
        guard let vc = PeripheralConnectedViewController.storyboardInstance() else { return }
        vc.centralManager = centralManager
        vc.peripheral = peripheral
        vc.peripheralManager = PeripheralManager(with: peripheral)
        //
        navigationController?.pushViewController(vc, animated: true)
        //
    }
}

    // MARK: - UITableViewDelegate
extension PeripheralsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "reuseCell")! as UITableViewCell
        //
        let peripheralsArray = Array(peripherals)
        let peripheral = peripheralsArray[indexPath.row]
        //
        cell.textLabel?.text = peripheral.name ?? "NO NAME"
        
        switch peripheral.state {
        case .connected:
            cell.detailTextLabel?.text = "connected"
        case .connecting:
            cell.detailTextLabel?.text = "connecting"
        case .disconnected:
            cell.detailTextLabel?.text = "disconnected"
        case .disconnecting:
            cell.detailTextLabel?.text = "disconnecting"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //
        let peripheralsArray = Array(peripherals)
        let peripheral = peripheralsArray[indexPath.row]
        //
        centralManager?.connect(peripheral, options: nil)
    }
}

    // MARK: - CBCentralManagerDelegate Methods
extension PeripheralsViewController: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("Connected to \(String(describing: peripheral.name))")
        didTapConnect(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected peripheral \(String(describing: peripheral.name))")
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            scanBtn.isEnabled = true
            startScanning()
        }
        else {
            // do something like alert the user that ble is not on
            updateStatusText("Bluetooth Disabled")
            scanBtn.isEnabled = false
            peripherals.removeAll()
            tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        peripherals.insert(peripheral)
        tableView.reloadData()
    }
}
