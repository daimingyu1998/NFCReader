//
//  dataManager.swift
//  New
//
//  Created by Eric on 2020/7/5.
//  Copyright © 2020 Eric. All rights reserved.
//

import Foundation
import Charts
class DataManager
{
    var entries = [BarChartDataEntry]()
    enum DataType {
        case Celsius
        case Fahrenheit
        case Light
    }
    func creatData(from sensorRecord: SensorRecord, in type: DataType) ->ChartData?
    {
        print(sensorRecord.data.count)
        entries.removeAll()
        for sensorData in sensorRecord.data {
            let x = sensorData.time.timeIntervalSince(sensorRecord.data.first!.time)
            var y = 0.0
            switch type {
            case .Celsius:
                if sensorData.datatype == 0 {
                    y = Double(sensorData.value)
                }
                else{
                    continue
                }
            case .Fahrenheit:
                if sensorData.datatype == 0 {
                    y = Double(sensorData.value) * 1.8 + 32
                }
                else{
                    continue
                }
            case .Light:
                if sensorData.datatype == 1 {
                    y = Double(sensorData.value)
                }
                else{
                    continue
                }
            }
            
            entries.append(BarChartDataEntry(x: x,y: y))
        }
        print(entries)
        var set = LineChartDataSet(entries: entries, label: "temperature")
        if (type == .Celsius || type == .Fahrenheit)
        {
            set = LineChartDataSet(entries: entries, label: "temperature")
        }
        else if type == .Light
        {
            set = LineChartDataSet(entries: entries, label: "brightness")
        }
        set.drawCirclesEnabled = true
        set.mode = .linear
        set.lineWidth = 1.5
        set.circleRadius = 5
        set.setCircleColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
        set.setColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.drawVerticalHighlightIndicatorEnabled = false
        let gradientColors = [#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor,UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [0, 1] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        set.drawFilledEnabled = true
        set.highlightColor = .red
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        return data
    }
    
}
