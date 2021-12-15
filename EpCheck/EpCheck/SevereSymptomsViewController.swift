//
//  SevereSymptomsViewController.swift
//  EpCheck
//
//  Created by Joshua Sylvester on 7/22/18.
//  Copyright © 2018 joshuasylvester. All rights reserved.
//

import UIKit

class SevereSymptomsViewController: UIViewController {
    
    @IBAction func lungButton(_ sender: Any) {
     performSegue(withIdentifier: "toInject", sender: self)
    }
    
    @IBAction func heartButton(_ sender: Any) {
        performSegue(withIdentifier: "toInject", sender: self)
    }
    
    @IBAction func throatButton(_ sender: Any) {
        performSegue(withIdentifier: "toInject", sender: self)
    }
    @IBAction func mouthButton(_ sender: Any) {
        performSegue(withIdentifier: "toInject", sender: self)
    }
    @IBAction func skinButton(_ sender: Any) {
        performSegue(withIdentifier: "toInject", sender: self)
    }
    
    @IBAction func otherButton(_ sender: Any) {
        performSegue(withIdentifier: "toInject", sender: self)
    }
    @IBAction func gutButton(_ sender: Any) {
        performSegue(withIdentifier: "toInject", sender: self)
    }
    @IBAction func noneButton(_ sender: Any) {
         performSegue(withIdentifier: "toMild", sender: self)
    }
    @IBAction func toHome(_ sender: Any) {
        performSegue(withIdentifier: "toHomeFromSev", sender: self)
    }
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
