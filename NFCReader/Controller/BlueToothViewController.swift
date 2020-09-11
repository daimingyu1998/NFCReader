//
//  BlueToothViewController.swift
//  NFCReader
//
//  Created by Eric on 2020/9/10.
//  Copyright © 2020 Eric. All rights reserved.
//

import UIKit
import CoreBluetooth

class BlueToothViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    enum SendDataError: Error{
        case CharaterisitcNotFound
    }
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
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found:\(peripheral.name)")
        guard peripheral.name != nil else{
            return
        }
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
            print("Found:\(uuidString)")
        }
    }
    func sendData(_ data: Data, uuidString:String, writeType: CBCharacteristicWriteType) throws{
        guard let charateristic = charDictionary[uuidString] else{
            throw SendDataError.CharaterisitcNotFound
        }
        connectPeripheral.writeValue(data, for: charateristic, type: writeType)
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("ERROR:\(error!)")
            return
        }
        if characteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
        {
            let data = characteristic.value!
            DispatchQueue.main.async {
                var string = data.hexEncodedString()
                print(string)
                
            }
        }
    }


}
