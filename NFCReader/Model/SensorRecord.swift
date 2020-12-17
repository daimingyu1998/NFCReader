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
    enum dataType {
        case Celsius
        case Fahrenheit
        case Light
    }
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
    func getAverageTemp(in type: dataType) -> Double?{
        var count = 0
        if data.isEmpty == true{
            return nil
        }
        else{
            var sum = 0.0
            for eachdata in data{
                switch type {
                case .Celsius:
                    if eachdata.datatype == 0{
                        sum += eachdata.value
                        count += 1
                    }
                case .Fahrenheit:
                    if eachdata.datatype == 0{
                        sum += eachdata.value * 1.8 + 32
                        count += 1
                    }
                case .Light:
                    if eachdata.datatype == 1{
                        sum += eachdata.value
                        count += 1
                    }
                    
                }
            }
            let avg = sum/Double(count)
            print(avg)
            return avg
        }
    }
}
