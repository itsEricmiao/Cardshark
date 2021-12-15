//
//  mildSympVC.swift
//  EpCheck
//
//  Created by Joshua Sylvester on 7/23/18.
//  Copyright © 2018 joshuasylvester. All rights reserved.
//

import UIKit

class mildSympVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func noseButton(_ sender: Any) {
        if(noseCounter == 0){
            self.noseButtonOut.backgroundColor = UIColor.red
            noseCounter+=1
            globalCounter+=1
            if(globalCounter >= 2){
                performSegue(withIdentifier: "toInjectFromMild", sender: self)
            }
        }
        else{
            self.noseButtonOut.backgroundColor = UIColor(rgb:0x008080)
            noseCounter-=1
            globalCounter-=1
        }
    }
    
    
    @IBAction func mouthButton(_ sender: Any) {
        if(mouthCounter == 0){
            self.mouthButtonOut.backgroundColor = UIColor.red
            mouthCounter+=1
            globalCounter+=1
            if(globalCounter >= 2){
                performSegue(withIdentifier: "toInjectFromMild", sender: self)
            }
        }
        else{
            self.mouthButtonOut.backgroundColor = UIColor(rgb:0x008080)
            mouthCounter-=1
            globalCounter-=1
        }
    }
    
    @IBAction func skinButton(_ sender: Any) {
        if(skinCounter == 0){
            self.skinButtonOut.backgroundColor = UIColor.red
            skinCounter+=1
            globalCounter+=1
            if(globalCounter >= 2){
                performSegue(withIdentifier: "toInjectFromMild", sender: self)
            }
        }
        else{
            self.skinButtonOut.backgroundColor = UIColor(rgb:0x008080)
            skinCounter-=1
            globalCounter-=1
        }
    }
    @IBAction func gutButton(_ sender: Any) {
        if(gutCounter == 0){
            self.gutButtonOut.backgroundColor = UIColor.red
            gutCounter+=1
            globalCounter+=1
            if(globalCounter >= 2){
                performSegue(withIdentifier: "toInjectFromMild", sender: self)
            }
        }
        else{
            self.gutButtonOut.backgroundColor = UIColor(rgb:0x008080)
            gutCounter-=1
            globalCounter-=1
        }
    }
    @IBAction func toHome(_ sender: Any) {
        performSegue(withIdentifier: "toHomeFromMild", sender: self)
    }
    
    @IBAction func noneButton(_ sender: Any) {
        performSegue(withIdentifier: "toWatch", sender: self)
    }
    @IBAction func doneButton(_ sender: Any) {
        performSegue(withIdentifier: "toWatch", sender: self)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var gutButtonOut: UIButton!
    @IBOutlet weak var skinButtonOut: UIButton!
    @IBOutlet weak var mouthButtonOut: UIButton!
    @IBOutlet weak var noseButtonOut: UIButton!
    
    var noseCounter = 0
    var gutCounter = 0
    var mouthCounter = 0
    var skinCounter = 0
    var globalCounter = 0
    

}
