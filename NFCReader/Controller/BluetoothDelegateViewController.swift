//
//  BluetoothDelegateViewController.swift
//  NFCReader
//
//  Created by Eric on 2020/9/24.
//  Copyright © 2020 Eric. All rights reserved.
//

import UIKit
import CoreBluetooth
class BluetoothDelegateViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var connectPeripheral: CBPeripheral!
    var charDictionary = [String: CBCharacteristic]()
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: .global())
    }
    func isPaired() -> Bool{
        let user = UserDefaults.standard
        if let uuidString = user.string(forKey: "KEY_PERIPHERAL_UUID"){
            let uuid = UUID(uuidString: uuidString)
            let list = centralManager.retrievePeripherals(withIdentifiers: [uuid!])
            if list.count > 0{
                connectPeripheral = list.first!
                connectPeripheral.delegate = self
                return true
            }
        }
        return false
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else{
            return
        }
        if isPaired(){
            centralManager.connect(connectPeripheral, options: nil)
        }else
        {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                central.stopScan()
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else{
            return
        }
        //        DispatchQueue.main.async {
        //            self.text.text += "Found:\(peripheral.name!)\n"
        //        }
        guard peripheral.name == "WRST-MON" else{
            return
        }
        central.stopScan()
        let user = UserDefaults.standard
        user.set(peripheral.identifier.uuidString, forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
        connectPeripheral = peripheral
        connectPeripheral.delegate = self
        centralManager.connect(connectPeripheral, options: nil)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        charDictionary = [:]
        peripheral.discoverServices(nil)
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else
        {
            print("ERROR:\(error!)")
            return
        }
        for service in peripheral.services!{
            connectPeripheral.discoverCharacteristics(nil, for: service)
            
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else{
            print("ERROR:\(error!)")
            return
        }
        for charateristic in service.characteristics!{
            let uuidString = charateristic.uuid.uuidString
            charDictionary[uuidString] = charateristic
            
        }
    }
    
}
