//
//  File.swift
//  NFCReader
//
//  Created by Eric on 2020/7/28.
//  Copyright © 2020 Eric. All rights reserved.
//

import Foundation
import RealmSwift
class SensorData:Object
{
    @objc dynamic var time = Date()
    @objc dynamic var value = 0.0
    @objc dynamic var datatype: Int = 0
    convenience init(refValue: Int, thermValue: Int, type: Int) {
        self.init()
        let ref = Double(refValue)
        let therm = Double(thermValue)
        self.datatype = type
        self.time = Date()
        let tempConv = therm / ref
        let tempx = (((( log10(tempConv) / log10(2.718))) / 4330.0) + ( 1.0 / 298.15))
        value =  (1.0 / tempx) - 273.15
    }
    convenience init(value: Double, type: Int) {
        self.init()
        self.time = Date()
        self.datatype = type
        self.value = value*0.9/(Double(2^14-1))
        self.value = (self.value - 0.125)/1000000
        self.value = self.value * 40000
    }
    convenience init(value: Int, type: Int){
        self.init()
        self.time = Date()
        self.datatype = type
        self.value = Double(value)*0.9/Double(pow(2.0, 14.0)-1)
    }
    
    
}
