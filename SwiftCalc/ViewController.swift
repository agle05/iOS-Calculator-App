import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var allButtons: [UIButton]!
    
    @IBOutlet weak var displayLabel: UILabel!
    
    @IBOutlet weak var clearButton: UIButton!
    
    private var isTypingNumber = false        // Are we in the middle of typing a number?
    private var firstNumber: Double = 0       // First operand
    private var currentOperator: String?      // Current operator pressed (+, −, etc)
    private var expression = ""
    private var justCalculated = false
    
    private var acTitle: NSAttributedString {
        NSAttributedString(string: "AC", attributes: [
            .font: UIFont.systemFont(ofSize: 30, weight: .bold),
            .foregroundColor: UIColor.black
        ])
    }

    private var ceTitle: NSAttributedString {
        NSAttributedString(string: "CE", attributes: [
            .font: UIFont.systemFont(ofSize: 30, weight: .bold),
            .foregroundColor: UIColor.black
        ])
    }

    
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
        guard let number = sender.configuration?.title else { return }
        
        if justCalculated {
            // Start new expression
            expression = number
            displayLabel.text = expression
            justCalculated = false
            clearButton.setAttributedTitle(ceTitle, for: .normal)
            return
        }
        
        expression += number
        displayLabel.text = expression
        isTypingNumber = true
        
        // change AC to CE
        clearButton.setAttributedTitle(ceTitle, for: .normal)


    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        guard let operation = sender.configuration?.title else { return }
        print("Operator pressed: \(operation)")
            
        if operation == "AC" {
            // Full clear
            expression = ""
            displayLabel.text = "0"
            isTypingNumber = false
            
            // Reset button title to AC just to be safe
            clearButton.setAttributedTitle(acTitle, for: .normal)

            return
        }
        
        if operation == "CE" {
            print("CE pressed, clearing last entry...")
            removeLastNumberEntry()
            print("Expression after CE:", expression)
            if expression.isEmpty {
                clearButton.setAttributedTitle(acTitle, for: .normal)

                print("Expression empty, reset button to AC")
            }
            return
        }

        if justCalculated {
            // Append operator to result
            justCalculated = false
            if let resultText = displayLabel.text {
                expression = resultText + operation
                displayLabel.text = expression
                clearButton.setAttributedTitle(ceTitle, for: .normal)
                return
            }
        }

        if operation == "=" {
            calculateResult()
            justCalculated = true
            clearButton.setAttributedTitle(acTitle, for: .normal)
            return
        }

        // Handle operators (+, −, ×, ÷)
        if expression.isEmpty {
            // Only allow minus at start for negative number
            if operation == "−" {
                expression += operation
                displayLabel.text = expression
            }
            return
        }

        if let lastChar = expression.last, isOperator(String(lastChar)) {
            if operation == "−" && (lastChar == "×" || lastChar == "÷") {
                // Allow minus after multiply/divide for negative number
                expression += operation
            } else {
                // Replace last operator with the new one
                expression = String(expression.dropLast()) + operation
            }
        } else {
            // Append operator normally
            expression += operation
        }

        displayLabel.text = expression
        isTypingNumber = false
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
        for op in ["+", "-", "×", "÷"] {
            if let range = expression.range(of: op) {
                let firstPart = String(expression[..<range.lowerBound])
                let secondPart = String(expression[range.upperBound...])
                
                // Convert to Double
                if let firstNum = Double(firstPart), let secondNum = Double(secondPart) {
                    var result: Double = 0
                    switch op {
                    case "+": result = firstNum + secondNum
                    case "-": result = firstNum - secondNum
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
    
    private func removeLastNumberEntry() {
        guard !expression.isEmpty else {
            displayLabel.text = "0"
            return
        }

        // Remove the last character (digit, operator, etc.)
        expression.removeLast()

        // If expression is now empty, reset to 0 and return AC mode
        if expression.isEmpty {
            displayLabel.text = "0"
            clearButton.setAttributedTitle(acTitle, for: .normal)
        } else {
            displayLabel.text = expression
        }
    }


    
}
