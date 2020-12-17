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
class TestController: UIViewController,ChartViewDelegate {
    @IBOutlet weak var text: UITextView!
    var NFCReaderMain = NFCReader()
    var dataManager = DataManager()
    var frameLayout: StackFrameLayout!
    let saveButton = NKButton.DefaultButton(title: "Save", color: UIColor(red:0.25, green:0.39, blue:0.80, alpha:1.00))
    let startButton = NKButton.DefaultButton(title: "Start", color: UIColor(red:0.42, green:0.67, blue:0.91, alpha:1.00))
    override func viewDidLoad() {
        super.viewDidLoad()
        //NFCReaderMain.instruction = "2100070001010E00"
        NFCReaderMain.mode = 0
        text.text = ""
        setButton()
    }
    @objc func startButtonPressed(_ sender: UIButton) {
        let testTime = 1
        NFCReaderMain.testTime = testTime
        NFCReaderMain.sensorRecord = nil
        NFCReaderMain.startSession()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.NFCReaderMain.dataReady == true
            {
                DispatchQueue.main.async {
                    self.text.text = self.NFCReaderMain.text
                }
                timer.invalidate()
            }
        }
        
    }
    @objc func saveButtonPressed(_ sender: UIButton) {
//        guard NFCReaderMain.dataReady == true else{
//            let alert = UIAlertController(title: "Save Failed", message: "There is no valid data currently", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alert.addAction(okAction)
//            self.present(alert, animated: true,completion:nil)
//            return
//        }
//        let realm = try! Realm()
//        do {
//            try realm.write{
//                realm.add(NFCReaderMain.sensorRecord!)
//            }
//            let alert = UIAlertController(title: "Save Successful", message: "Please view the data in the History", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alert.addAction(okAction)
//            self.present(alert, animated: true,completion:nil)
//            NotificationCenter.default.post(name:  Notification.Name("updateTV"), object: nil)
//
//        }
//        catch{
//            print("realm writing error")
//        }
        
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

