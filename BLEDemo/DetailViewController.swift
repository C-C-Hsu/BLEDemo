//
//  DetailViewController.swift
//  BLEDemo
//
//  Created by 許家旗 on 2016/10/8.
//  Copyright © 2016年 許家旗. All rights reserved.
//

import UIKit
import CoreBluetooth

class DetailViewController: UIViewController, CBPeripheralDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var inputTextField: UITextField!

    @IBOutlet weak var logTextView: UITextView!
    
    var targetPeripheral:CBPeripheral?
    var targetCharacteristic:CBCharacteristic?
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        let viewController = self.presentingViewController as!
        MasterViewController
        NSLog(viewController.detailInfo)
        
        logTextView.text = ""
        targetPeripheral?.delegate = self
        // Listener
        targetPeripheral?.setNotifyValue(true, for: targetCharacteristic!)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        targetPeripheral?.setNotifyValue(false, for: targetCharacteristic!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        guard let text = inputTextField.text else {
            return
        }
        
        guard text.characters.count > 0 else {
            return
        }
        
        // Dismiss the keyboard
        inputTextField.resignFirstResponder()
        guard let dataWillSend = text.data(using: .utf8) else {
            return
        }
        
        targetPeripheral?.writeValue(dataWillSend, for: targetCharacteristic!, type: .withoutResponse)
        // Type: withResponse會等待回應
    }

    // 藍芽接收到資料回應
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        let content = String(data: characteristic.value!, encoding: .utf8)
        
        if content != nil {
            
            NSLog("Receive: \(content)")
            
            logTextView.text! += content!
        }
    }
    
    // withResponse對應func
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        NSLog("didWriteValueFor")
    }
}

