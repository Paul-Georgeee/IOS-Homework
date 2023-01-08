//
//  Navigation.swift
//  ITSC
//
//  Created by nju on 2022/11/17.
//

import UIKit

class Navigation: UINavigationController {

    var url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tableViewController = self.viewControllers[0] as? TableViewController {
            tableViewController.url = self.url
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
