import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    private var isTypingNumber = false
    private var firstNumber: Double = 0
    private var currentOperator: String?
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
        
        registerForTraitChanges(
            [UITraitVerticalSizeClass.self, UITraitHorizontalSizeClass.self]
        ) { [weak self] (sender: UIViewController, previousTraitCollection: UITraitCollection) in
            DispatchQueue.main.async {
                self?.updateButtonCorners()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateButtonCorners()
    }
    
    private func updateButtonCorners() {
        for button in allButtons {
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        guard let number = sender.configuration?.title else { return }
        
        if justCalculated {
            expression = number
            displayLabel.text = expression
            justCalculated = false
            clearButton.setAttributedTitle(ceTitle, for: .normal)
            return
        }
        
        // Prevent multiple decimal points
        if number == "." && expression.contains(".") && !isOperatorPresentInExpression() {
            return
        }
        
        expression += number
        displayLabel.text = expression
        isTypingNumber = true
        
        clearButton.setAttributedTitle(ceTitle, for: .normal)
    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        guard let operation = sender.configuration?.title else { return }
            
        if operation == "AC" {
            resetCalculator()
            return
        }
        
        if operation == "CE" {
            removeLastNumberEntry()
            if expression.isEmpty {
                clearButton.setAttributedTitle(acTitle, for: .normal)
            }
            return
        }

        if justCalculated {
            if let resultText = displayLabel.text {
                expression = resultText + operation
                displayLabel.text = expression
                clearButton.setAttributedTitle(ceTitle, for: .normal)
                justCalculated = false
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
            if operation == "−" {
                expression += operation
                displayLabel.text = expression
            }
            return
        }

        if let lastChar = expression.last, isOperator(String(lastChar)) {
            if operation == "−" && (lastChar == "×" || lastChar == "÷") {
                expression += operation
            } else {
                expression = String(expression.dropLast()) + operation
            }
        } else {
            expression += operation
        }

        displayLabel.text = expression
        isTypingNumber = false
    }
    
    private func formatResult(_ result: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        formatter.numberStyle = .decimal
        
        return formatter.string(from: NSNumber(value: result)) ?? "Error"
    }
    
    private func isOperator(_ char: String) -> Bool {
        return ["+", "−", "×", "÷"].contains(char)
    }
    
    private func isOperatorPresentInExpression() -> Bool {
        return expression.contains { char in
            isOperator(String(char))
        }
    }
    
    private func calculateResult() {
        // Improved calculation logic to handle multiple operations
        var components = expression.components(separatedBy: ["+", "−", "×", "÷"])
        var operators = expression.filter { isOperator(String($0)) }.map { String($0) }
        
        // First handle multiplication and division
        while let multiplyDivideIndex = operators.firstIndex(where: { $0 == "×" || $0 == "÷" }) {
            guard multiplyDivideIndex < components.count - 1 else { break }
            
            let left = Double(components[multiplyDivideIndex]) ?? 0
            let right = Double(components[multiplyDivideIndex + 1]) ?? 0
            let op = operators[multiplyDivideIndex]
            
            var result: Double = 0
            switch op {
            case "×": result = left * right
            case "÷": result = right != 0 ? left / right : 0
            default: break
            }
            
            components.replaceSubrange(multiplyDivideIndex...multiplyDivideIndex+1, with: [String(result)])
            operators.remove(at: multiplyDivideIndex)
        }
        
        // Then handle addition and subtraction
        var result = Double(components.first ?? "0") ?? 0
        for (index, op) in operators.enumerated() {
            guard index + 1 < components.count else { break }
            let nextNum = Double(components[index + 1]) ?? 0
            
            switch op {
            case "+": result += nextNum
            case "−": result -= nextNum
            default: break
            }
        }
        
        displayLabel.text = formatResult(result)
        expression = formatResult(result)
        isTypingNumber = false
    }
    
    private func removeLastNumberEntry() {
        guard !expression.isEmpty else {
            displayLabel.text = "0"
            return
        }

        expression.removeLast()
        
        if expression.isEmpty {
            displayLabel.text = "0"
            clearButton.setAttributedTitle(acTitle, for: .normal)
        } else {
            displayLabel.text = expression
        }
    }
    
    private func resetCalculator() {
        expression = ""
        displayLabel.text = "0"
        isTypingNumber = false
        justCalculated = false
        clearButton.setAttributedTitle(acTitle, for: .normal)
    }
}
