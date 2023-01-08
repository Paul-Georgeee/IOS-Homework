//
//  Calculator.swift
//  calculator
//
//  Created by nju on 2022/10/2.
//

import UIKit


class Calculator: NSObject {
    enum Operator {
        case UnaryOp((Double) -> Double)
        case BinaryOp((Double, Double) -> Double)
        case EqualOp
        case Clear
    }
    
    var operations = [
        "+": Operator.BinaryOp({
            (op1, op2) in
            return op1 + op2
        }),
        "-": Operator.BinaryOp({
            (op1, op2) in
            return op1 - op2
        }),
        "*": Operator.BinaryOp({
            (op1, op2) in
            return op1 * op2
        }),
        "/": Operator.BinaryOp({
            (op1, op2) in
            return op1 / op2
        }),
        "+/-": Operator.UnaryOp({
            op in
            return -op
        }),
        "%": Operator.UnaryOp({
            op in
            return op / 100
        }),
        "x^2": Operator.UnaryOp({
            op in
            return op * op
        }),
        "x^3": Operator.UnaryOp({
            op in
            return op * op * op
        }),
        "x^4": Operator.UnaryOp({
            op in
            return op * op * op * op
        }),
        "sin": Operator.UnaryOp({
            op in
            return sin(op)
        }),
        "cos": Operator.UnaryOp({
            op in
            return cos(op)
        }),
        "2^x": Operator.UnaryOp({
            op in
            return pow(2, op)
        }),
        "=": Operator.EqualOp,
        "clear": Operator.Clear

    ]
    
    
    var precedence = [
        "+" : 1,
        "-" : 1,
        "*" : 2,
        "/" : 2
    ]
    
    
    
    var operandStack = [Double]()
    
    var operatorStack = [String]()
    var funcStack = [(Double, Double) -> Double]()
    
    var beginFlag = false

    
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
    
    func eval() -> Double{
        var cnt = operatorStack.count
        if cnt == 1{
            return operandStack[0]
        }else {
            
            if cnt > 2{
                if precedence[operatorStack[1]] == 2{
                    let function = funcStack.remove(at: 1)
                    let op2 = operandStack.removeLast(), op1 = operandStack.removeLast()
                    operandStack.append(function(op1, op2))
                    operatorStack.remove(at: 1)
                }else{
                    let function = funcStack.removeFirst()
                    let op1 = operandStack.removeFirst(), op2 = operandStack[0]
                    operandStack[0] = function(op1, op2)
                    operatorStack.removeFirst()
                }
                
                cnt = cnt - 1
            }
            
            return getLabelNumber()
            
        }
    }
    
    func changeTopOp(operation:String) -> Double?{
     
        switch operations[operation]{
        case .BinaryOp(let function):
            let cnt = funcStack.count
            funcStack[cnt - 1] = function
            operatorStack[cnt - 1] = operation
            if cnt == 1{
                return operandStack[0]
            }else{
                return getLabelNumber()
            }
            
        case .EqualOp:
            funcStack.removeLast()
            operatorStack.removeLast()
            return finishEval()
        case .Clear:
            return clearStack()
        default:
            return nil
        }
        
        
    }
    
    func finishEval() -> Double{
        var tmp:Double

        if self.operatorStack.count == 0{
            tmp = self.operandStack.removeFirst()
        }else if self.operatorStack.count == 1{
            tmp = self.funcStack[0](operandStack[0], operandStack[1])
        }else if self.operatorStack.count == 2{
            let operator0 = self.operatorStack[0], operator1 = self.operatorStack[1]
            if self.precedence[operator0]! < self.precedence[operator1]!{
                tmp = funcStack[0](operandStack[0], funcStack[1](operandStack[1], operandStack[2]))
            }else{
                tmp = funcStack[1](funcStack[0](operandStack[0], operandStack[1]), operandStack[2])
            }
        }else{
            tmp = 0
        }
            
        self.clearStack()
        return tmp
    }
    
    func clearStack() -> Double{
        operandStack.removeAll()
        operatorStack.removeAll()
        funcStack.removeAll()
        return 0
    }
    
    
    
    func getOp(operation: String, operand: Double) -> Double?{

        let op = operations[operation]
        switch op{
        case .UnaryOp(let function):
            return function(operand)
        case .BinaryOp(let function):
            operandStack.append(operand)
            operatorStack.append(operation)
            funcStack.append(function)
            return eval()
        case .EqualOp:
            operandStack.append(operand)
            return finishEval()
        case .Clear:
            return clearStack()
        default:
            assert(false)
            
        }
    }
    
    
}
