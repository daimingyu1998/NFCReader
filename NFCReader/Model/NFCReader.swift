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
    var text: String = ""
    {
        didSet
        {
            delegate?.update()
        }
    }
    func startSession() {
        dataReady = false
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
        self.sensorRecord = SensorRecord()
        var time = 0
        session.connect(to: firstTag) { error in
            guard error == nil else{
                print("NFC: \(error!.localizedDescription)")
                session.invalidate(errorMessage: "Connection failure: \(error!.localizedDescription)")
                return
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                session.alertMessage = "Remaining time:\(self.testTime - time)"
                self.connectedTag = tag
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
                    print(statusStringSlice)
                    if statusStringSlice == "0002"
                    {
                        self.singleDataReady = true
                    }
                }
                self.connectedTag?.writeSingleBlock(requestFlags: [.highDataRate,.address], blockNumber: 0, dataBlock: Data(hexString: "0101070001010040")!){error in
                    guard error == nil else{
                        print(error)
                        return
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
                    let refStringSlice = string[refIndexmid..<refIndexend] + string[refIndexstart..<refIndexmid]
                    let therStringSlice = string[therIndexmid..<therIndexend] + string[therIndexstart..<therIndexmid]
                    let refValue = Int(refStringSlice, radix: 16) ?? 0
                    let thermValue = Int(therStringSlice, radix: 16) ?? 0
                    time += 1
                    if self.singleDataReady == true{
                        self.sensorRecord?.add(SensorData(refValue: refValue, thermValue: thermValue))
                        if  time == self.testTime + 1
                        {
                            session.alertMessage = "Scan complete"
                            session.invalidate()
                            timer.invalidate()
                            
                            self.dataReady = true
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

