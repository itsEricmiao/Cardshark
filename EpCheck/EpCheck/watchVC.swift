//
//  watchVC.swift
//  EpCheck
//
//  Created by Joshua Sylvester on 7/23/18.
//  Copyright © 2018 joshuasylvester. All rights reserved.
//

import UIKit

class watchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func call(_ sender: Any) {
        if let url = URL(string:"tel://" + "9186711626"){
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func instButton(_ sender: Any) {
        performSegue(withIdentifier: "toInstFromWatch", sender: self)
    }
    @IBAction func toHome(_ sender: Any) {
        performSegue(withIdentifier: "toHomeFromWatch", sender: self)
    }
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
