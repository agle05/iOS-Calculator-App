import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var allButtons: [UIButton]!
    
    @IBOutlet weak var displayLabel: UILabel!
    
    private var isTypingNumber = false        // Are we in the middle of typing a number?
    private var firstNumber: Double = 0       // First operand
    private var currentOperator: String?      // Current operator pressed (+, −, etc)
    private var expression = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for button in allButtons {
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        print("Button tapped")
        guard let number = sender.configuration?.title else { return }
        
        expression += number
        displayLabel.text = expression
        isTypingNumber = true
    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        guard let operation = sender.configuration?.title else { return }
        
        if operation == "AC" {
            expression = ""
            displayLabel.text = "0"
            isTypingNumber = false
            firstNumber = 0
            currentOperator = nil
        } else if operation == "=" {
            // Evaluate expression (you can use your existing logic or expand it)
            // For now, let's just compute basic 2-number operation as before
            
            // Parse expression here or keep your previous calculation logic
            calculateResult()
            
        } else {
            if expression.isEmpty {
                // Don't allow operator at start except minus (to allow negative numbers)
                if operation == "−" {
                    expression += operation
                    displayLabel.text = expression
                }
                return
            }
            
            if let lastChar = expression.last, isOperator(String(lastChar)) {
                // If last char is operator
                if operation == "−" && (lastChar == "×" || lastChar == "÷") {
                    // Allow minus after multiply/divide
                    expression += operation
                } else {
                    // Replace last operator with new operator
                    expression = String(expression.dropLast()) + operation
                }
            } else {
                // Append operator normally
                expression += operation
            }
            displayLabel.text = expression
            isTypingNumber = false
        }
        
        if operation == "AC" {
            displayLabel.text = "0"
            isTypingNumber = false
            firstNumber = 0
            currentOperator = nil
        } else if operation == "=" {
            guard let text = displayLabel.text,
                  let secondNumber = Double(text),
                  let op = currentOperator else { return }
            
            calculateResult()
            
        } else {
            if let currentText = displayLabel.text, let num = Double(currentText) {
                firstNumber = num
                currentOperator = operation
                isTypingNumber = false
            }
        }
    }
    
    private func formatResult(_ result: Double) -> String {
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(result))
        } else {
            return String(result)
        }
    }
    
    private func isOperator(_ char: String) -> Bool {
        return ["+", "−", "×", "÷"].contains(char)
    }
    
    private func calculateResult() {
        // Find first operator (left to right)
        for op in ["+", "−", "×", "÷"] {
            if let range = expression.range(of: op) {
                let firstPart = String(expression[..<range.lowerBound])
                let secondPart = String(expression[range.upperBound...])
                
                // Convert to Double
                if let firstNum = Double(firstPart), let secondNum = Double(secondPart) {
                    var result: Double = 0
                    switch op {
                    case "+": result = firstNum + secondNum
                    case "−": result = firstNum - secondNum
                    case "×": result = firstNum * secondNum
                    case "÷": result = secondNum != 0 ? firstNum / secondNum : 0
                    default: break
                    }
                    displayLabel.text = formatResult(result)
                    expression = formatResult(result)
                    isTypingNumber = false
                    return
                }
            }
        }
        // If no operator found or parse failed
        displayLabel.text = expression
    }
    
}
