//
//  ViewController.swift
//  TinyToyTank
//
//  Created by nju on 2022/12/15.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var tankAnchor: TinyToyTank._TinyToyTank?
    var isActionPlaying = false
    
    @IBAction func turretLeft(_ sender: Any) {
        if self.isActionPlaying{
            return
        }else{
            self.isActionPlaying = true
        }
        tankAnchor!.notifications.turretLeft.post()
    }
    @IBAction func turretRight(_ sender: Any) {
        if self.isActionPlaying{
            return
        }else{
            self.isActionPlaying = true
        }
        tankAnchor!.notifications.turretRight.post()
    }
    @IBAction func openFire(_ sender: Any) {
        if self.isActionPlaying{
            return
        }else{
            self.isActionPlaying = true
        }
        tankAnchor!.notifications.cannonFire.post()
    }
    @IBAction func tankLeft(_ sender: Any) {
        if self.isActionPlaying{
            return
        }else{
            self.isActionPlaying = true
        }
        tankAnchor!.notifications.tankLeft.post()
    }
    @IBAction func tankForward(_ sender: Any) {
        if self.isActionPlaying{
            return
        }else{
            self.isActionPlaying = true
        }
        tankAnchor!.notifications.tankForward.post()
    }
    @IBAction func tankRight(_ sender: Any) {
        if self.isActionPlaying{
            return
        }else{
            self.isActionPlaying = true
        }
        tankAnchor!.notifications.tankRight.post()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tankAnchor = try! TinyToyTank.load_TinyToyTank()
        tankAnchor?.actions.actionComplete.onAction = {
            _ in
            self.isActionPlaying = false
        }
        tankAnchor!.turret?.setParent(tankAnchor!.tank, preservingWorldTransform: true)
        arView.scene.anchors.append(tankAnchor!)

    }
}
