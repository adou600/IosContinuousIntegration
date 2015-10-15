//
//  DetailViewController.swift
//  IosContinuousIntegration
//
//  Created by Adrien Nicolet on 14/10/15.
//  Copyright © 2015 Adrien Nicolet. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {

    @IBOutlet weak var detailTextView: UITextView!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            
            //Only for test purposes, no real utility...
            performNetworkRequestAndUpdateDetails()
            
            if let textView = self.detailTextView {
                textView.text = detail.description
            }
        }
    }
    
    private func performNetworkRequestAndUpdateDetails() {
        Alamofire.request(.GET, "https://httpbin.org/get")
            .responseString { response in
                if let textView = self.detailTextView {
                    textView.text! += "\n" + response.result.value!
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


}

