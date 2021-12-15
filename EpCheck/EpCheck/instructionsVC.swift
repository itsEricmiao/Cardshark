//
//  instructionsVC.swift
//  EpCheck
//
//  Created by Joshua Sylvester on 7/23/18.
//  Copyright © 2018 joshuasylvester. All rights reserved.
//

import UIKit

class instructionsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func otherButton(_ sender: Any) {
        performSegue(withIdentifier: "toOtherInst", sender: self)
    }
    @IBAction func toHome(_ sender: Any) {
        performSegue(withIdentifier: "toHomeFromInst", sender: self)
    }
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func epipenButton(_ sender: Any) {
         performSegue(withIdentifier: "toEpiInstructions", sender: self)
    }
    
    @IBAction func auviButton(_ sender: Any) {
        performSegue(withIdentifier: "toAuviInst", sender: self)
    }
    @IBAction func impaxButton(_ sender: Any) {
        performSegue(withIdentifier: "toImpaxFromInst", sender: self)
    }
    
}
