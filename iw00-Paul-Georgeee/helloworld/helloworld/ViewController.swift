//
//  ViewController.swift
//  helloworld
//
//  Created by nju on 2022/9/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func showHelloWorld()
    {
        let alert = UIAlertController(title: "Hello World", message: "You click the button", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    var clickTimes = 0
    @IBOutlet weak var cnt: UILabel!
    @IBAction func count()
    {
        clickTimes = clickTimes + 1
        if clickTimes > 1{
            cnt.text = "You have clicked " + String(clickTimes) + " times"
        }else{
            cnt.text = "You have clicked " + String(clickTimes) + " time"
        }
        
    }
}

