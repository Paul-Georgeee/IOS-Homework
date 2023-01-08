//
//  TabBar.swift
//  ITSC
//
//  Created by nju on 2022/11/17.
//

import UIKit

class TabBar: UITabBarController {

    let urls = ["https://itsc.nju.edu.cn/xwdt/list.htm", "https://itsc.nju.edu.cn/tzgg/list.htm", "https://itsc.nju.edu.cn/wlyxqk/list.htm", "https://itsc.nju.edu.cn/aqtg/list.htm"]
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0..<self.viewControllers!.count{
            if let navigation = self.viewControllers![i] as? Navigation{
                navigation.url = self.urls[i]
            }
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
