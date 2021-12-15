//
//  otherInjectorVC.swift
//  EpCheck
//
//  Created by Joshua Sylvester on 7/23/18.
//  Copyright © 2018 joshuasylvester. All rights reserved.
//

import UIKit

class otherInjectorVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toHome(_ sender: Any) {
        performSegue(withIdentifier: "toHomeFromOtherInst", sender: self)
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
