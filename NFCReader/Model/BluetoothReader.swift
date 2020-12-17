//
//  BluetoothReader.swift
//  NFCReader
//
//  Created by Eric on 2020/9/24.
//  Copyright © 2020 Eric. All rights reserved.
//

import Foundation
import CoreBluetooth
class BluetoothReader: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    var centralManager: CBCentralManager!
    var connectPeripheral: CBPeripheral!
    var charDictionary = [String: CBCharacteristic]()
    var testTime = 5
    var sensorRecord: SensorRecord? = nil
    var dataReady = false
    var singleDataReady = false
    var testStart = false
    var testFinished = false
    var channel = 0
    func startSession() {
        testStart = true
        dataReady = false
        singleDataReady = false
        sensorRecord = SensorRecord()
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
            data = Data(hexString: "00")!
            self.sendData(data, uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E", writeType: .withoutResponse)
            self.testTime -= 1
            if self.testTime==0{
                self.testFinished = true
                self.testStart = false
                self.dataReady = true
                timer.invalidate()
            }
//            data = Data(hexString: "01")!
//            self.sendData(data, uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E", writeType: .withoutResponse)
//            data = Data(hexString: "02")!
//            self.sendData(data, uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E", writeType: .withoutResponse)
        }
        
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
            let string = data.hexEncodedString()
            switch channel {
            case 0:
                sensorRecord?.add(SensorData(value:Double(string) ?? 0, type: 1))
            default:
                print(1)
            }
        }
    }
    
    
}
