//
//  ViewController.swift
//  StanwoodDialog_iOS
//
//  Created by epeschard on 01/03/2018.
//  Distributed under MIT licence.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var launchesCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    func updateUI() {
        let launchCount = UserDefaults.standard.value(forKey: "numberOfAppStarts") as? Int
        launchesCount.text = "Launch: \(launchCount ?? 0)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

