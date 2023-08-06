//
//  ViewController.swift
//  carNavigationSystem
//
//  Created by K I on 2023/07/26.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var akasataButton: UIButton!
    @IBOutlet var nahamayaButton: UIButton!
    @IBOutlet var rawaButton: UIButton!
    //@IBOutlet var label:UILabel!
    var number:Int=0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        akasataButton.setTitle("あか\nさた", for: .normal)
        nahamayaButton.setTitle("なは\nまや", for: .normal)
        rawaButton.setTitle("らわ", for: .normal)
        //label.text="s"

    }
    
    @IBAction func plus(){
        number=number + 1
        //label.textColor=UIColor.black
    }


}
