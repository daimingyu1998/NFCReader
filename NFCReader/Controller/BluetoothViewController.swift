//
//  BlueToothViewController.swift
//  NFCReader
//
//  Created by Eric on 2020/9/10.
//  Copyright © 2020 Eric. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: BluetoothDelegateViewController {
    enum SendDataError: Error{
        case CharaterisitcNotFound
    }
    @IBOutlet weak var text0: UITextField!
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    var state = 0
    @IBOutlet weak var text: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        text0.isUserInteractionEnabled = false
        text1.isUserInteractionEnabled = false
        text2.isUserInteractionEnabled = false
        text.isEditable = false
    }
    
    func sendData(_ data: Data, uuidString:String, writeType: CBCharacteristicWriteType){
        guard let charateristic = charDictionary[uuidString] else{
            print("error")
            DispatchQueue.main.async {
                self.text.text += "fail to write \(data.hexEncodedString())\n"
            }
            
            return
        }
        connectPeripheral.writeValue(data, for: charateristic, type: writeType)
        DispatchQueue.main.async {
            self.text.text += "success to write \(data.hexEncodedString())\n"
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("ERROR:\(error!)")
            return
        }
        if characteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
        {
            DispatchQueue.main.async {
                self.text.text += "did change value\n"
            }
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
