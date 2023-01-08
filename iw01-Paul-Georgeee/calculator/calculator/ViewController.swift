//
//  ViewController.swift
//  calculator
//
//  Created by nju on 2022/10/2.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var displayStr: UILabel!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    func removeScienceBtn()
    {
        let btn = [btn0, btn1, btn2, btn3, btn4]
        for (index, view) in  buttonStackView!.arrangedSubviews.enumerated(){
            if let stackview = view as? UIStackView{
                stackview.removeArrangedSubview(btn[index]!)
            }
        }
    }
    
    func showScienceBtn()
    {
        let btn = [btn0, btn1, btn2, btn3, btn4]
        for (index, view) in  buttonStackView!.arrangedSubviews.enumerated(){
            if let stackview = view as? UIStackView{
                stackview.insertArrangedSubview(btn[index]!, at: 0)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.displayStr.text = "0"
        if self.view!.frame.height > self.view!.frame.width{
            self.removeScienceBtn()
        }else{
            self.showScienceBtn()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.height > size.width{
            self.removeScienceBtn()
        }else{
            self.showScienceBtn()
        }
    }
    
    var digit: String{
        get{
            return self.displayStr.text!
        }
        
        set{
            self.displayStr.text! = newValue
        }
    }
    
    
    var isTyping = false
    var isZero = true       //whether the label is zero only
    var hasPoint = false    //whether there has met a point
    var enterBinaryOp = false     //whether has entered an Binary op
    
    @IBAction func NumberTouched(_ sender: UIButton) {
        enterBinaryOp = false
        if isTyping == false{
            hasPoint = false
            isZero = false
            isTyping = true
            switch sender.currentTitle! {
            case "0":
                isZero = true
                digit = "0"
            case ".":
                hasPoint = true
                digit = "0."
            default :
                digit = sender.currentTitle!
            }
        }else{
            switch sender.currentTitle! {
            case "0":
                if isZero{
                    return
                }else{
                    digit = digit + "0"
                }
            case ".":
                isZero = false
                if hasPoint{
                    return
                }else{
                    hasPoint = true
                    digit = digit + "."
                }
            default:
                if isZero{
                    digit = sender.currentTitle!
                    isZero = false
                }else{
                    digit = digit + sender.currentTitle!
                }
            }
        }
    }
    
    var cal: Calculator = Calculator()
    
    
    func showAlert(description: String){
        let alert = UIAlertController(title: "Alert", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func OperatorTouched(_ sender: UIButton) {
        isTyping = false
        let op = sender.currentTitle!

        if enterBinaryOp == false{
            if let res = cal.getOp(operation: op, operand: Double(digit)!) {
                if res.isInfinite || res.isNaN {
                    digit = String(cal.clearStack())
                    showAlert(description: "Div By Zero Error Or The Result is too Big")
                }else{
                    digit = String(res)
                }
                
            }

        }else{
            let res = cal.changeTopOp(operation:op)
            if res == nil{
                showAlert(description: "连续摁两次运算符且第二次为单目运算符的功能不支持")
            }else if res!.isNaN || res!.isInfinite {
                digit = String(cal.clearStack())
                showAlert(description: "Div By Zero Error!")
            }else{
                digit = String(res!)
            }
        }
        
        if op == "+" || op == "-" || op == "*" || op == "/"{
            enterBinaryOp = true
        }else{
            enterBinaryOp = false
        }
    }
}

