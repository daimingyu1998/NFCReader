//
//  File.swift
//  NFCReader
//
//  Created by Eric on 2020/7/28.
//  Copyright © 2020 Eric. All rights reserved.
//

import Foundation
import RealmSwift
class SensorRecord: Object{
    var data = List<SensorData>()
    @objc dynamic var name = ""
    convenience init(name: String){
        self.init()
        self.name = name
    }
    func add(_ new: SensorData){
        self.data.append(new)
    }
    func getStartTime() -> Date? {
        if let data = data.first
        {
            return data.time
        }
        else{
            print("record have no data")
            return nil
        }
    }
    func getEndTime() -> Date? {
        if let data = data.last
        {
            return data.time
        }
        else{
            print("record have no data")
            return nil
        }
    }
    func getAverageTemp() -> Double?{
        if data.isEmpty == true{
            return nil
        }
        else{
            var sum = 0.0
            for eachdata in data{
                sum += eachdata.tempInC
            }
            let avg = sum/Double(data.count)
            print(avg)
            return avg
        }
    }
}
