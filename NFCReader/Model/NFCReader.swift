//
//  NFCReader.swift
//  NFCReader
//
//  Created by Eric on 2020/7/13.
//  Copyright © 2020 Eric. All rights reserved.
//

import Foundation
import CoreNFC
class NFCReader: NSObject, NFCTagReaderSessionDelegate {
    var delegate : NFCReaderDelegate?
    var tagSession: NFCTagReaderSession?
    var connectedTag: NFCISO15693Tag?
    var testTime = 5
    var sensorRecord: SensorRecord? = nil
    var dataReady = false
    var singleDataReady = false
    var testFinished = false
    var instruction = "2100070001010E40"
    var mode = 0
    var text: String = ""
    {
        didSet
        {
            delegate?.update()
        }
    }
    func startSession() {
        dataReady = false
        singleDataReady = false
        tagSession = NFCTagReaderSession(pollingOption: [.iso15693], delegate: self, queue: .main)
        tagSession?.alertMessage = "Hold the top of your iPhone near the sensor board"
        tagSession?.begin()
    }
    
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC: session did become active")
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if readerError.code != .readerSessionInvalidationErrorUserCanceled {
                print("NFC: \(readerError.localizedDescription)")
                session.invalidate(errorMessage: "Connection failure: \(readerError.localizedDescription)")
            }
        }
    }
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("NFC: did detect tags")
        
        guard let firstTag = tags.first else { return }
        guard case .iso15693(let tag) = firstTag else { return }
        if self.sensorRecord == nil{
            self.sensorRecord = SensorRecord()
        }
        var time = 0
        let totalTime = testTime > 15 ? 15 : testTime
        let remainTime = testTime - totalTime
        self.text = ""
        session.connect(to: firstTag) { error in
            guard error == nil else{
                print("NFC: \(error!.localizedDescription)")
                session.invalidate(errorMessage: "Connection failure: \(error!.localizedDescription)")
                return
            }
            self.connectedTag = tag
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                session.alertMessage = "Remaining time: \(self.testTime - time) secs"
                self.connectedTag?.readSingleBlock(requestFlags: [.highDataRate,.address], blockNumber: 0){ (data, error) in
                    guard error == nil else{
                        session.invalidate(errorMessage: "Error while reading block: \(error!.localizedDescription)")
                        return
                    }
                    let string = data.hexEncodedString().uppercased()
                    let statusIndexstart = string.index(string.startIndex, offsetBy: 0)
                    let statusIndexmid = string.index(string.startIndex, offsetBy: 2)
                    let statusIndexend = string.index(string.startIndex, offsetBy: 4)
                    let statusStringSlice = string[statusIndexstart..<statusIndexmid] + string[statusIndexmid..<statusIndexend]
                    self.singleDataReady = false
                    if statusStringSlice == "0002"
                    {
                        self.singleDataReady = true
                    }
                }
                self.connectedTag?.writeSingleBlock(requestFlags: [.highDataRate,.address], blockNumber: 0, dataBlock: Data(hexString: self.instruction)!){error in
                    guard error == nil else{
                        print(error ?? "error")
                        return
                    }
                }
                if (self.mode == 1){
                    self.connectedTag?.writeSingleBlock(requestFlags: [.highDataRate,.address], blockNumber: 2, dataBlock: Data(hexString: "00002D0000000000")!){error in
                        guard error == nil else{
                            print(error ?? "error")
                            return
                        }
                    }
                }
                if (self.mode == 0){
                    self.connectedTag?.writeSingleBlock(requestFlags: [.highDataRate,.address], blockNumber: 2, dataBlock: Data(hexString: "0000000000000000")!){error in
                        guard error == nil else{
                            print(error ?? "error")
                            return
                        }
                    }
                }
                
                self.connectedTag?.readSingleBlock(requestFlags: [.highDataRate,.address], blockNumber: 9){ (data, error) in
                    guard error == nil else{
                        session.invalidate(errorMessage: "Error while reading block: \(error!.localizedDescription)")
                        return
                    }
                    let string = data.hexEncodedString().uppercased()
                    let refIndexstart = string.index(string.startIndex, offsetBy: 0)
                    let refIndexmid = string.index(string.startIndex, offsetBy: 2)
                    let refIndexend = string.index(string.startIndex, offsetBy: 4)
                    let therIndexstart = string.index(string.startIndex, offsetBy: 4)
                    let therIndexmid = string.index(string.startIndex, offsetBy: 6)
                    let therIndexend = string.index(string.startIndex, offsetBy: 8)
                    let lightIndexstart = string.index(string.startIndex, offsetBy: 8)
                    let lightIndexmid = string.index(string.startIndex, offsetBy: 10)
                    let lightIndexend = string.index(string.startIndex, offsetBy: 12)
                    let refStringSlice = string[refIndexmid..<refIndexend] + string[refIndexstart..<refIndexmid]
                    let therStringSlice = string[therIndexmid..<therIndexend] + string[therIndexstart..<therIndexmid]
                    let lightStringSlice = string[lightIndexmid..<lightIndexend] + string[lightIndexstart..<lightIndexmid]
                    let refValue = Int(refStringSlice, radix: 16) ?? 0
                    let thermValue = Int(therStringSlice, radix: 16) ?? 0
                    let lightValue = Int(lightStringSlice, radix: 16) ?? 0
                    self.text += "Block" + String(9) + ": " + data.hexEncodedString().uppercased() + "\n"
                    let data1start = string.index(string.startIndex, offsetBy: 0)
                    let data1mid = string.index(string.startIndex, offsetBy: 2)
                    let data1end = string.index(string.startIndex, offsetBy: 4)
                    let data2start = string.index(string.startIndex, offsetBy: 4)
                    let data2mid = string.index(string.startIndex, offsetBy: 6)
                    let data2end = string.index(string.startIndex, offsetBy: 8)
                    let data3start = string.index(string.startIndex, offsetBy: 8)
                    let data3mid = string.index(string.startIndex, offsetBy: 10)
                    let data3end = string.index(string.startIndex, offsetBy: 12)
                    let data4start = string.index(string.startIndex, offsetBy: 8)
                    let data4mid = string.index(string.startIndex, offsetBy: 10)
                    let data4end = string.index(string.startIndex, offsetBy: 12)
                    let data1StringSlice = string[data1mid..<data1end] + string[data1start..<data1mid]
                    let data2StringSlice = string[data2mid..<data2end] + string[data2start..<data2mid]
                    let data3StringSlice = string[data3mid..<data3end] + string[data3start..<data3mid]
                    let data4StringSlice = string[data4mid..<data4end] + string[data4start..<data4mid]
                    print(data1StringSlice)
                    let data1Value = Int(data1StringSlice, radix: 16) ?? 0
                    let data2Value = Int(data2StringSlice, radix: 16) ?? 0
                    let data3Value = Int(data3StringSlice, radix: 16) ?? 0
                    let data4Value = Int(data4StringSlice, radix: 16) ?? 0
                    print(data1Value)
                    self.text += "value1 = " + String(SensorData(value: data1Value, type: 2).value) + "\n"
                    self.text += "value2 = " + String(SensorData(value: data2Value, type: 2).value) + "\n"
                    self.text += "value3 = " + String(SensorData(value: data3Value, type: 2).value) + "\n"
                    self.text += "value4 = " + String(SensorData(value: data4Value, type: 2).value) + "\n"
                    time += 1
                    if self.singleDataReady == true{
                        self.sensorRecord?.add(SensorData(refValue: refValue, thermValue: thermValue, type: 0))
                        self.sensorRecord?.add(SensorData(value: Double(lightValue), type: 1))
                        if  time == totalTime + 1
                        {
                            if remainTime <= 0{
                                session.alertMessage = "Scan complete"
                                session.invalidate()
                                timer.invalidate()
                                
                                self.dataReady = true
                            }
                            else{
                                session.alertMessage = "Please wait for the next pop up"
                                print(remainTime)
                                session.invalidate()
                                timer.invalidate()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                    self.singleDataReady = false
                                    self.testTime = remainTime - 4
                                    self.startSession()
                                }
                            }
                            
                        }
                    }
                }
                
                
            }
            
        }
    }
}


extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}
extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

