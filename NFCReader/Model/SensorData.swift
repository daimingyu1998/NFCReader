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
    @objc dynamic var tempInC = 0.0
    @objc dynamic var tempInF = 0.0
    convenience init(refValue: Int, thermValue: Int) {
        self.init()
        let ref = Double(refValue)
        let therm = Double(thermValue)
        self.time = Date()
        let tempConv = therm / ref
        let tempx = (((( log10(tempConv) / log10(2.718))) / 4330.0) + ( 1.0 / 298.15))
        tempInC =  (1.0 / tempx) - 273.15
        tempInF = tempInC*1.8 + 32
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
    }
    
}
