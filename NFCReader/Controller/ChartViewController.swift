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
class ChartViewController: UIViewController,ChartViewDelegate {
    @IBOutlet weak var avg: UILabel!
    var NFCReader1 = NFCReader()
    var temperatureManager = TemperatureManager()
    var frameLayout: StackFrameLayout!
    let saveButton = NKButton.DefaultButton(title: "Save", color: UIColor(red:0.25, green:0.39, blue:0.80, alpha:1.00))
    let startButton = NKButton.DefaultButton(title: "Start", color: UIColor(red:0.42, green:0.67, blue:0.91, alpha:1.00))
    @IBOutlet weak var chartView: UIView!
    lazy var lineChart: LineChartView = {
        let chart = LineChartView()
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
        return chart
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        
        lineChart.delegate = self
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 30, height: self.view.frame.width/1)
        lineChart.center = view.center
        view.addSubview(lineChart)
        avg.isHidden = true
        
    }
    
    @objc func startButtonPressed(_ sender: UIButton) {
        NFCReader1.startSession()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.NFCReader1.dataReady == true
            {
                self.lineChart.data = self.temperatureManager.creatData(from: self.NFCReader1.sensorRecord!)
                let average:Double = self.NFCReader1.sensorRecord?.getAverageTemp() ?? 0.0
                DispatchQueue.main.async {
                    self.avg.text = String(format: "Average Temperature: %.3f", average)
                    self.avg.textColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                    self.avg.isHidden = false
                }
                
                timer.invalidate()
            }
        }
        
    }
    @objc func saveButtonPressed(_ sender: UIButton) {
        
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
    func setButton(){
        startButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
        startButton.setGradientColor([UIColor(white: 1.0, alpha: 0.5), UIColor(white: 1.0, alpha: 0.0)], for: .normal)
        startButton.setGradientColor([UIColor(white: 1.0, alpha: 0.0), UIColor(white: 1.0, alpha: 0.5)], for: .highlighted)
        startButton.titleLabel?.textAlignment = .center
        startButton.loadingIndicatorAlignment = .center
        startButton.hideTitleWhileLoading = true
        startButton.underlineTitleDisabled = true
        startButton.loadingIndicatorStyle = .ballBeat
        startButton.isRoundedButton = false
        startButton.cornerRadius = 20.0
        startButton.extendSize = CGSize(width: 60, height: 30)
        startButton.addTarget(self, action: #selector(onButtonSelected), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        
        saveButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
        saveButton.setGradientColor([UIColor(white: 1.0, alpha: 0.5), UIColor(white: 1.0, alpha: 0.0)], for: .normal)
        saveButton.setGradientColor([UIColor(white: 1.0, alpha: 0.0), UIColor(white: 1.0, alpha: 0.5)], for: .highlighted)
        saveButton.hideTitleWhileLoading = true
        saveButton.loadingIndicatorAlignment = .center
        saveButton.loadingIndicatorStyle = .ballClipRotatePulse
        saveButton.extendSize = CGSize(width: 60, height: 30)
        saveButton.cornerRadius = 20.0
        saveButton.addTarget(self, action: #selector(onButtonSelected), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        saveButton.isRoundedButton = true
        
        frameLayout = StackFrameLayout(axis: .horizontal, distribution: .center, views: [startButton, saveButton])
        frameLayout.isIntrinsicSizeEnabled = true
        frameLayout.spacing = 30
        
        view.addSubview(startButton)
        view.addSubview(saveButton)
        view.addSubview(frameLayout)
    }
}
extension NKButton {
    
    class func DefaultButton(title: String, color: UIColor) -> NKButton {
        let button = NKButton(title: title, buttonColor: color, shadowColor: color)
        button.title = title
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        
        button.setBackgroundColor(color, for: .normal)
        button.setShadowColor(color, for: .normal)
        
        //        button.shadowOffset = CGSize(width: 0, height: 5)
        //        button.shadowOpacity = 0.6
        //        button.shadowRadius = 10
        
        button.isRoundedButton = true
        
        return button
    }
    
}

