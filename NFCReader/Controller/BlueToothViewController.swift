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
    @IBOutlet weak var text0: UITextField!
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    var state = 0
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
    func sendData(_ data: Data, uuidString:String, writeType: CBCharacteristicWriteType){
        guard let charateristic = charDictionary[uuidString] else{
            print("error")
            return
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
                let string = data.hexEncodedString()
                switch self.state {
                case 0:
                    self.text0.text = string
                case 1:
                    self.text1.text = string
                case 2:
                    self.text2.text = string
                default:
                    return
                }
            }
        }
    }

    @IBAction func start(_ sender: UIButton) {
        guard connectPeripheral != nil else{
            return
        }
        let uuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
        guard charDictionary[uuid] != nil else
        {
            return
        }
        self.connectPeripheral.setNotifyValue(true, for: charDictionary[uuid]!)
        var data = Data()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
            switch self.state {
            case 0:
                data = Data(hexString: "00")!
                self.sendData(data, uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E", writeType: .withoutResponse)
            case 1:
                data = Data(hexString: "01")!
                self.sendData(data, uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E", writeType: .withoutResponse)
            case 2:
                data = Data(hexString: "02")!
                self.sendData(data, uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E", writeType: .withoutResponse)
            default:
                return
            }
            self.state = (self.state + 1) % 3
        }
    }
    
}
