//
//  SecondViewController.swift
//  New
//
//  Created by Eric on 2020/7/4.
//  Copyright © 2020 Eric. All rights reserved.
//

import UIKit
import Charts
import NKButton
import FrameLayoutKit
import NVActivityIndicatorView
import RealmSwift
class ChartViewController: UIViewController,ChartViewDelegate {
    @IBOutlet weak var avg: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var picker: UIPickerView!
    var NFCReader1 = NFCReader()
    var temperatureManager = TemperatureManager()
    var frameLayout: StackFrameLayout!
    let saveButton = NKButton.DefaultButton(title: "Save", color: UIColor(red:0.25, green:0.39, blue:0.80, alpha:1.00))
    let startButton = NKButton.DefaultButton(title: "Start", color: UIColor(red:0.42, green:0.67, blue:0.91, alpha:1.00))
    var pickerMinuteData = { () -> [Int] in
        var list = [Int]()
        for i in 0..<60{
            list.append(i)
        }
        return list
    }()
    var pickerSecondData = { () -> [Int] in
        var list = [Int]()
        for i in 0..<60{
            if i % 15 == 0{
                list.append(i)
            }
        }
        return list
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        setChart()
        avg.isHidden = true
        picker.delegate = self
        picker.dataSource = self
    }
    
    @IBAction func didUpdateSegment(_ sender: UISegmentedControl) {
        guard self.NFCReader1.dataReady == true else{
            return
        }
        updateData()
    }
    @objc func startButtonPressed(_ sender: UIButton) {
        let testTime = picker.selectedRow(inComponent: 0) * 60 + picker.selectedRow(inComponent: 1) * 15
        guard testTime > 0 else{
            let alert = UIAlertController(title: "Start Failed", message: "Please choose a valid time", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true,completion:nil)
            return
        }
        NFCReader1.testTime = testTime
        NFCReader1.sensorRecord = nil
        NFCReader1.startSession()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.NFCReader1.dataReady == true
            {
                self.updateData()
                timer.invalidate()
            }
        }
        
    }
    @objc func saveButtonPressed(_ sender: UIButton) {
        guard NFCReader1.dataReady == true else{
            let alert = UIAlertController(title: "Save Failed", message: "There is no valid data currently", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true,completion:nil)
            return
        }
        let realm = try! Realm()
        do {
            try realm.write{
                realm.add(NFCReader1.sensorRecord!)
            }
            NotificationCenter.default.post(name:  Notification.Name("updateTV"), object: nil)
           
        }
        catch{
            print("realm writing error")
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let viewSize = view.bounds.size
        let contentSize = frameLayout.sizeThatFits(CGSize(width: viewSize.width * 0.9, height: viewSize.height))
        frameLayout.frame = CGRect(x: (viewSize.width - contentSize.width)/2 , y: (viewSize.height - contentSize.height) - 100, width: contentSize.width, height: contentSize.height)
    }
    @objc func onButtonSelected(_ button: NKButton) {
        print("Button Selected")
        button.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            button.isLoading = false
        }
    }
    func updateData(){
        switch self.segment.selectedSegmentIndex {
        case 0:
            self.chart.data = self.temperatureManager.creatData(from: self.NFCReader1.sensorRecord!, in: .Celsius)
            let average:Double = self.NFCReader1.sensorRecord?.getAverageTemp(in: .Celsius) ?? 0.0
            DispatchQueue.main.async {
                self.avg.text = String(format: "Average Temp: %.3f °C", average)
                self.avg.textColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                self.avg.isHidden = false
            }
        case 1:
            self.chart.data = self.temperatureManager.creatData(from: self.NFCReader1.sensorRecord!, in: .Fahrenheit)
            let average:Double = self.NFCReader1.sensorRecord?.getAverageTemp(in: .Fahrenheit) ?? 0.0
            DispatchQueue.main.async {
                self.avg.text = String(format: "Average Temp: %.3f °F", average)
                self.avg.textColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                self.avg.isHidden = false
            }
        default:
            return
        }
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
    func setButton(){
        startButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
        startButton.setGradientColor([UIColor(white: 1.0, alpha: 0.5), UIColor(white: 1.0, alpha: 0.0)], for: .normal)
        startButton.setGradientColor([UIColor(white: 1.0, alpha: 0.0), UIColor(white: 1.0, alpha: 0.5)], for: .highlighted)
        startButton.loadingIndicatorAlignment = .center
        startButton.hideTitleWhileLoading = true
        startButton.underlineTitleDisabled = true
        startButton.loadingIndicatorAlignment = .center
        startButton.loadingIndicatorStyle = .ballBeat
        startButton.isRoundedButton = true
        startButton.cornerRadius = 20.0
        startButton.extendSize = CGSize(width: 60, height: 30)
        
        startButton.addTarget(self, action: #selector(onButtonSelected), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        
        saveButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
        saveButton.setGradientColor([UIColor(white: 1.0, alpha: 0.5), UIColor(white: 1.0, alpha: 0.0)], for: .normal)
        saveButton.setGradientColor([UIColor(white: 1.0, alpha: 0.0), UIColor(white: 1.0, alpha: 0.5)], for: .highlighted)
        saveButton.titleLabel?.textAlignment = .center
        saveButton.hideTitleWhileLoading = true
        saveButton.underlineTitleDisabled = true
        saveButton.loadingIndicatorAlignment = .center
        saveButton.loadingIndicatorStyle = .ballClipRotatePulse
        saveButton.isRoundedButton = true
        saveButton.cornerRadius = 20.0
        saveButton.extendSize = CGSize(width: 60, height: 30)
        
        saveButton.addTarget(self, action: #selector(onButtonSelected), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        
        
        frameLayout = StackFrameLayout(axis: .horizontal, distribution: .center, views: [startButton, saveButton])
        frameLayout.isIntrinsicSizeEnabled = true
        frameLayout.spacing = 30
        
        view.addSubview(startButton)
        view.addSubview(saveButton)
        view.addSubview(frameLayout)
    }
}
extension ChartViewController: UIPickerViewDelegate,UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return pickerMinuteData.count
        default:
            return pickerSecondData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        //将图片设为PickerView选型
        var pickerLabel = view as? UILabel
        if pickerLabel == nil{
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 18)
            pickerLabel?.textAlignment = .center
        }
        var string = ""
        switch component {
        case 0:
            string = String(pickerMinuteData[row]) + " mins"
        default:
            string =  String(pickerSecondData[row]) + " secs"
        }
        pickerLabel?.text = string
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    
}
extension NKButton {
    
    class func DefaultButton(title: String, color: UIColor) -> NKButton {
        let button = NKButton(title: title, buttonColor: color, shadowColor: color)
        button.title = title
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 18)
        
        button.setBackgroundColor(color, for: .normal)
        button.setShadowColor(color, for: .normal)
        
        //        button.shadowOffset = CGSize(width: 0, height: 5)
        //        button.shadowOpacity = 0.6
        //        button.shadowRadius = 10
        
        button.isRoundedButton = true
        
        return button
    }
    
}

