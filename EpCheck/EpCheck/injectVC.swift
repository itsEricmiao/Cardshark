//
//  injectVC.swift
//  EpCheck
//
//  Created by Joshua Sylvester on 7/23/18.
//  Copyright © 2018 joshuasylvester. All rights reserved.
//

import UIKit

class injectVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toHome(_ sender: Any) {
        performSegue(withIdentifier: "toHomeFromInject", sender: self)
    }
    
    @IBAction func call(_ sender: Any) {
        if let url = URL(string:"tel://" + "911"){
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func instructionsButton(_ sender: Any) {
        performSegue(withIdentifier: "toIInstructionsFromInject", sender: self)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
