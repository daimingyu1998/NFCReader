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
    @IBOutlet weak var segment1: UISegmentedControl!
    @IBOutlet weak var segment2: UISegmentedControl!
    var sensorRecord: SensorRecord?
    var dataManager = DataManager()
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
        let marker = BalloonMarker(color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chart
        marker.minimumSize = CGSize(width: 60, height: 30)
        chart.marker = marker
    }
    func updateData(){
        switch self.segment2.selectedSegmentIndex {
        case 0:
            segment1.isHidden = false
            switch self.segment1.selectedSegmentIndex {
            case 0:
                self.chart.data = self.dataManager.creatData(from: self.sensorRecord!, in: .Celsius)
                let average:Double = self.sensorRecord?.getAverageTemp(in: .Celsius) ?? 0.0
                DispatchQueue.main.async {
                    self.avg.text = String(format: "Average Temp: %.3f °C", average)
                    self.avg.textColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                    self.avg.isHidden = false
                }
            case 1:
                self.chart.data = self.dataManager.creatData(from: self.sensorRecord!, in: .Fahrenheit)
                let average:Double = self.sensorRecord?.getAverageTemp(in: .Fahrenheit) ?? 0.0
                DispatchQueue.main.async {
                    self.avg.text = String(format: "Average Temp: %.3f °F", average)
                    self.avg.textColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                    self.avg.isHidden = false
                }
            default:
                return
            }
        case 1:
            segment1.isHidden = true
            self.chart.data = self.dataManager.creatData(from: self.sensorRecord!, in: .Light)
            let average:Double = self.sensorRecord?.getAverageTemp(in: .Light) ?? 0.0
            DispatchQueue.main.async {
                self.avg.text = String(format: "Average Lumi: %.3f lm", average)
                self.avg.textColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                self.avg.isHidden = false
            }
        default:
            return
        }
    }
    
    @IBAction func didChange(_ sender: UISegmentedControl) {
        updateData()
    }
    
}
