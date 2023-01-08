[TOC]

# iw01

## 实现的功能

<img src="./report.assets/截屏2022-10-03 下午7.09.10.png" alt="截屏2022-10-03 下午7.09.10" style="zoom:25%;" />

- 基本的计算器功能，各按键功能对应于iphone中的计算器

- 支持运算符的优先级功能，即按下`1 + 2 * 3` 的结果为7而不是9

- 支持在计算过程中多次按下二元运算符，具体如下，按下`1 + 2 * + 4` 结果将会是7。下列截图分别是按下`1 + 2 *`，`1 + 2 * +`，`1 + 2 * + 4 = `的运行截图，在按下第二个加号时根据优先级前面的可以计算，因此显示为3；按下乘号时前面的加法不能先算，因此显示2（按照iphone中计算器的设定）

  

  <img src="./report.assets/截屏2022-10-03 下午7.14.01.png" alt="截屏2022-10-03 下午7.14.01" style="zoom:25%;" /><img src="./report.assets/截屏2022-10-03 下午7.15.14.png" alt="截屏2022-10-03 下午7.15.14" style="zoom:25%;" /><img src="./report.assets/截屏2022-10-03 下午7.15.53.png" alt="截屏2022-10-03 下午7.15.53" style="zoom:25%;" />

- 一些避免计算器崩溃或出现错误的设计

  - 不会显示多个小数点

  - 不会显示多个没有意义的前缀零

  - 在按下一个二元运算符之后，再按下一个单目操作符`+/- %`会提示错误（和iPhone中的计算器设定不太一样）

  - 除以0错误

    

    <img src="./report.assets/截屏2022-10-03 下午7.22.14.png" alt="截屏2022-10-03 下午7.22.14" style="zoom:25%;" /><img src="./report.assets/截屏2022-10-03 下午7.57.03.png" alt="截屏2022-10-03 下午7.57.03" style="zoom:25%;" />

- 横屏不会出现奇怪的画面，后来实现了科学计算器，见下

<img src="./report.assets/截屏2022-10-23 下午7.44.24.png" alt="截屏2022-10-23 下午7.44.24" style="zoom:25%;" />

## 实现细节

### calculator类

用栈来实现优先级有关的操作，一个栈存运算符，一个存运算符对应的操作的匿名函数，一个存操作数

#### getOp函数

运算符按钮被绑定到该函数，调用时参数为label上面显示的数字和运算符

- 单目运算符，则直接结算返回结果，因为单目运算符不用考虑优先级
- 双目运算符，则将运算符和操作数对应入栈，并调用eval对栈内的运算符和操作数进行计算，调用getLabelNumber得到当前应该显示的数字
- clear，则清空运算符栈和操作数栈
- 等号，则将栈里面剩余的操作数和运算符计算出结果并返回

由于只涉及加减乘除而且没有括号，只有当入栈的运算符的优先级高于栈顶的优先级时（即原栈顶为+-，刚进入的为*/），才需要优先结算刚入栈的运算符，否则按顺序计算即可。

按照iphone中的设计，可以顺序计算时显示中间结果，有需要优先计算时显示当前的第一个操作数

```swift
func getLabelNumber() -> Double{
        let cnt = operatorStack.count
        let operator1 = operatorStack[cnt - 1]
        let operator2 = operatorStack[cnt - 2]
        
        if precedence[operator1]! > precedence[operator2]! {
            return operandStack.last!
        }else{
            return funcStack[0](operandStack[0], operandStack[1])
        }
    }
```

这里没有将计算的结果直接保存到栈内，是为了后续实现可以计算`1 + 2 * + 3`的功能，不难看出，要不要计算`1 + 2`至少要等到按入第三个数字才能决定，而我们每次是在按入运算符才将数字和运算符一起送个这个类，因此只有当栈内的运算符个数等于三时，才能将前面的计算结果保存到栈内

```swift
func eval() -> Double{
        var cnt = operatorStack.count
        if cnt == 1{
            return operandStack[0]
        }else {
            
            if cnt > 2{
            //根据优先级计算栈内的操作数
            }
            
            return getLabelNumber()
            
        }
    }
```

#### changeOp函数

当按下`1 + 2 * +`，第二次按加号会调用该函数，该函数改变运算符栈内的内容，并调用getLabelNumber返回需要显示的值

#### 其他函数

剩余的函数较为简单，即对于于清空栈和将栈内剩余的内容计算出一个结果



### view control

#### OperatorTouched函数

当按下运算符时调用，根据是否已经按下一个二元运算符来决定调用getOp还是changeOp

同时检查是否发生除0错误，一开始想使用异常处理，后来想起直接根据结果是否为inf和nan来判断更简单，如果出现错误，则清空栈并出现Alert

而当按下二元运算符后再按一元运算符时，同样出现alert

#### NumberTouched函数

当按下数字和小数点时调用，将按下的数字拼接上去

同时用变量isZero来跟踪当前的值是不是0，用于避免出现00，01等；变量hasPoint用来判断是否已经有小数点，用于避免一个数字中出现多个小数点；而变量isTyping则是用来判断是否正在键入数字（该值在按下运算符时被设为false）





## 后面添加的横屏科学计算功能

通过检查当前的height和width判断当前的横屏还是竖屏状态，如果是横屏则把用于科学计算的按钮加入到每一行的stackview当中，如果是竖屏，则从每一行的stackview中删除对应的按钮

<img src="./report.assets/截屏2022-10-23 下午7.44.24.png" alt="截屏2022-10-23 下午7.44.24" style="zoom:25%;" />

仅添加了5个新的按钮，~~因为这五个不用考虑非法情况（例如取对数要大于0）~~，主要还是体验一下用代码操纵view的感觉

首先获取对应按钮的outlet以及组织所有按键的stackView，并在每次高和宽发生变化时进行修改。以在变为横屏时插入按钮为例，通过调用`insertArrangedSubview`，将按钮插入到对应的stackview中。变为竖屏时则调用`removeArrangeSubview`即可

```swift
@IBOutlet weak var buttonStackView: UIStackView!
@IBOutlet weak var btn0: UIButton!
...

func showScienceBtn()
{
  let btn = [btn0, btn1, btn2, btn3, btn4]
  for (index, view) in  buttonStackView!.arrangedSubviews.enumerated(){
    if let stackview = view as? UIStackView{
      stackview.insertArrangedSubview(btn[index]!, at: 0)
    }
  }
}

override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
  if size.height > size.width{
    self.removeScienceBtn()
  }else{
    self.showScienceBtn()
  }
}
```

