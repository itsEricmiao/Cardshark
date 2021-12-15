//
//  ViewController.swift
//  EpCheck
//
//  Created by Joshua Sylvester on 7/22/18.
//  Copyright © 2018 joshuasylvester. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func yesButton(_ sender: Any) {
         performSegue(withIdentifier: "toInjectFromHome", sender: self)
    }
    @IBAction func maybeButton(_ sender: Any) {
        performSegue(withIdentifier: "segToSev", sender: self)
    }
    @IBAction func toSev(_ sender: Any) {
        performSegue(withIdentifier: "segToSev", sender: self)
    }
}

