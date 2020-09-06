//
//  HistoryDetailViewController.swift
//  NFCReader
//
//  Created by Eric on 2020/9/6.
//  Copyright © 2020 Eric. All rights reserved.
//Second

import UIKit
import Charts
class HistoryDetailViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var avg: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var segment: UISegmentedControl!
    var sensorRecord: SensorRecord?
    var temperatureManager = TemperatureManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        setChart()
        updateData()
    }

    func setChart(){
        chart.delegate = self
        chart.rightAxis.enabled = false
        chart.leftAxis.labelFont = .boldSystemFont(ofSize: 10)
        chart.leftAxis.labelTextColor = .black
        chart.leftAxis.axisLineColor = .black
        chart.leftAxis.labelPosition = .outsideChart
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        chart.xAxis.labelTextColor = .black
        chart.xAxis.axisLineColor = .black
        chart.xAxis.drawGridLinesEnabled = false
        chart.dragEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.pinchZoomEnabled = false
    }
    func updateData(){
        switch self.segment.selectedSegmentIndex {
        case 0:
            chart.data = self.temperatureManager.creatData(from: sensorRecord!, in: .Celsius)
        case 1:
            chart.data = self.temperatureManager.creatData(from: sensorRecord!, in: .Fahrenheit)
        default:
            return
        }
    }

}
