//
//  DetailViewController.swift
//  BLEDemo
//
//  Created by 許家旗 on 2016/10/8.
//  Copyright © 2016年 許家旗. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var inputTextField: UITextField!

    @IBOutlet weak var logTextView: UITextView!
    
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
        
        
    }

}

