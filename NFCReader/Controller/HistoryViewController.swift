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
    var sensorRecords: Results<SensorRecord>!
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("updateTV"), object: nil)
        tableView.rowHeight = 80.0
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        sensorRecords = realm.objects(SensorRecord.self)
        return sensorRecords.count

    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let realm = try! Realm()
        sensorRecords = realm.objects(SensorRecord.self)
        let date = sensorRecords[indexPath.row].getStartTime()!
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:m:ss"
        cell.textLabel?.text = df.string(from: date)
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
        performSegue(withIdentifier: "detail", sender: indexPath.row)
    }
    @objc func update(){
        tableView.reloadData()
    }
}
extension HistoryViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else{return nil}
        let realm = try! Realm()
        let deleteAction = SwipeAction(style: .destructive, title: "Delete"){ action, indexPath in
            if let recordForDeletion = self.sensorRecords?[indexPath.row]{
                do{
                    try realm.write{
                        realm.delete(recordForDeletion)
                    }
                }catch{
                    print("deletion error")
                }
            }
            tableView.reloadData()
        }
        deleteAction.image = UIImage(named: "delete")
        return [deleteAction]
    }
    
    
}


