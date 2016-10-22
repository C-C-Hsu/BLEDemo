//
//  MasterViewController.swift
//  BLEDemo
//
//  Created by 許家旗 on 2016/10/8.
//  Copyright © 2016年 許家旗. All rights reserved.
//

import UIKit
import CoreBluetooth

let target_characteristic_uuid = "ffe1" // KentDongle

class MasterViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()

    // For Servies/Characteristic scan
    var detailInfo = ""
    var restServies = [CBService]()
    
    var centralManager:CBCentralManager?
    
    // For Talking support
    var shouldTalking = false
    var talkingPeripheral:CBPeripheral?
    var talkingCharacteristic:CBCharacteristic?
    
    var allItems = [String:DiscoveredItem]()
    
    var lastReloadDate:Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ////
//        self.navigationItem.leftBarButtonItem = self.editButtonItem
//
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        self.navigationItem.rightBarButtonItem = addButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        centralManager = CBCentralManager(delegate: self, queue:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if talkingPeripheral != nil {
            
            centralManager?.cancelPeripheralConnection(talkingPeripheral!)
            talkingPeripheral = nil
            talkingCharacteristic = nil
            
            // Resume the scan
            startToScan()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            if self.tableView.indexPathForSelectedRow != nil {
                
//                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
                controller.targetPeripheral = talkingPeripheral
                controller.targetCharacteristic = talkingCharacteristic
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        return false
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let allKeys = Array(allItems.keys)
        let targetKey = allKeys[indexPath.row]
        let targetItem = allItems[targetKey]
        
        let name = targetItem?.peripheral.name ?? "Unknown"
        cell.textLabel!.text = "\(name) RSSI: \(targetItem!.lastRSSI)"
        
        let lastSeenSecondsAgo = String(format: "%.1f", Date().timeIntervalSince(targetItem!.lastSeenDateTime))
        cell.detailTextLabel!.text = "Last seen \(lastSeenSecondsAgo) seconds ago."
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        shouldTalking = true
        
        startToConnect(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        shouldTalking = false
        
        startToConnect(indexPath)
    }
    
    func startToScan() {
        
        NSLog("Start Scan.")
        
        let options = [CBCentralManagerOptionShowPowerAlertKey:true]
        
        centralManager?.scanForPeripherals(withServices: nil, options: options)
    }
    
    func stopScanning() {
    
        centralManager?.stopScan()
    }
    
    func startToConnect(_ indexPath: IndexPath) {
        
        let allKeys = Array(allItems.keys)
        let targetKey = allKeys[indexPath.row]
        let targetItem = allItems[targetKey]
        
        NSLog("Connecting to \(targetKey)...")
        
        // 藍芽連線
        centralManager?.connect(targetItem!.peripheral, options: nil)
    }
    
    func showAlert(_ msssage:String) {
        
        let alert = UIAlertController(title: "狀態", message: msssage, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: CBCentralManagerDelegate Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        let state = central.state
        
        if state != .poweredOn {
            // Error oucur.
            showAlert("BLE is not available. (Error: \(state.rawValue))")
        } else {
            
            startToScan()
        }
    }
 
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
     
        let existItem = allItems[peripheral.identifier.uuidString]
        
        if existItem == nil {
            
            // It is a new item
            let name = (peripheral.name ?? "Unknown")
            NSLog("Discovered: \(name), RSSI: \(RSSI), UUID: \(peripheral.identifier.uuidString), AdvData: \(advertisementData.description)) ")
        }
        let newItem = DiscoveredItem(newperipheral: peripheral, RSSI: Int(RSSI))
        allItems[peripheral.identifier.uuidString] = newItem
        
        // Decide when to reload TableView
        let now = Date()
        
        if existItem == nil || lastReloadDate == nil || now.timeIntervalSince(lastReloadDate!) > 2.0 {
            
            lastReloadDate = now
            
            // Refresh TableView
            tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        let name = peripheral.name ?? "UnKnown"
        
        NSLog("Connected to \(name)")
        
        stopScanning()
        
        // Try to discovery the services of peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        showAlert("Fail to connect!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        let name = peripheral.name ?? "UnKnown"
        
        NSLog("Disconnected to \(name)")

        startToScan()
    }
    
    // MARK: CBPeripheralDelegate Methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            
            // 藍芽取消連線
            centralManager?.cancelPeripheralConnection(peripheral)
            
            NSLog("Error: \(error!)")
            
            return
        }
        
        // Perpare for collect detailInfo
        detailInfo = ""
        restServies.removeAll()
        
        // Perpare to discovery characteristic for each service
        restServies += peripheral.services!
        
        // Pick the first one
        let targetService = restServies.first
        restServies.remove(at: 0)
        
        peripheral.discoverCharacteristics(nil, for: targetService!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            
            // 藍芽取消連線
            centralManager?.cancelPeripheralConnection(peripheral)
            
            NSLog("Error: \(error!)")
            
            return
        }
        
        detailInfo += "*** Peripheral: \(peripheral.name!)\n \(peripheral.services!.count) services.\n"
        
        detailInfo += "** Service: \(service.uuid.uuidString)\n \(service.characteristics!.count) characteristics.\n"
        
        for tmp in service.characteristics! {
            
            detailInfo += "* Characteristic: \(tmp.uuid.uuidString)\n"
            
            // Chack if shouldTalking is true and it is what we are looking for.
            if shouldTalking && tmp.uuid.uuidString.lowercased() == target_characteristic_uuid {
                
                restServies.removeAll()
                
                talkingPeripheral = peripheral
                talkingCharacteristic = tmp
                
                self.performSegue(withIdentifier: "showDetail", sender: nil)
                return
            }
        }
        
        detailInfo += "-------------------------------------\n"
        
        if restServies.isEmpty {
            
            showAlert(detailInfo)
            
            centralManager?.cancelPeripheralConnection(peripheral)
        } else {
            
            // Pick the first one
            let targetService = restServies.first
            restServies.remove(at: 0)
            
            peripheral.discoverCharacteristics(nil, for: targetService!)
        }
    }

}
