//
//  DiscoveredItem.swift
//  BLEDemo
//
//  Created by 許家旗 on 2016/10/8.
//  Copyright © 2016年 許家旗. All rights reserved.
//

import Foundation
import CoreBluetooth

struct DiscoveredItem {

    var peripheral:CBPeripheral
    var lastRSSI:Int
    var lastSeenDateTime:Date
    
    init(newperipheral:CBPeripheral, RSSI:Int) {
        
        peripheral = newperipheral
        lastRSSI = RSSI
        lastSeenDateTime = Date()
    }
}
