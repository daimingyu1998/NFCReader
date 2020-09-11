//
//  ViewController.swift
//  NFCReader
//
//  Created by Eric on 2020/7/13.
//  Copyright © 2020 Eric. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift
class HistoryViewController: UITableViewController {
    
    var NFCReader1 = NFCReader()
    var sensorRecords: Results<SensorRecord>!
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        sensorRecords = realm.objects(SensorRecord.self)
        return sensorRecords.count

    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let realm = try! Realm()
        sensorRecords = realm.objects(SensorRecord.self)
        cell.textLabel?.text = sensorRecords[indexPath.row].getStartTime()?.description
        return cell
         
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail"
        {
            let destVC = segue.destination as! HistoryDetailViewController
            destVC.sensorRecord = sensorRecords[sender as! Int]
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: indexPath)
    }
}


