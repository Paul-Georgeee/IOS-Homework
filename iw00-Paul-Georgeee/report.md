[TOC]

# iw00

## 实现的功能

- 按键计数
- 按键弹出helloworld框

## 实现细节

分别将两个按键绑定到下面两个函数即可

```swift
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
```

