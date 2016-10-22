//
//  SensorDetailViewController.swift
//  BLEDemo
//
//  Created by 許家旗 on 2016/10/22.
//  Copyright © 2016年 許家旗. All rights reserved.
//

import UIKit
import CoreBluetooth

class SensorDetailViewController: UIViewController, CBPeripheralDelegate {

    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
