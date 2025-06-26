import UIKit

class ViewController: UIViewController {

    @IBOutlet var allButtons: [UIButton]!
    
    @IBOutlet weak var displayLabel: UILabel!
    
    private var isTypingNumber = false        // Are we in the middle of typing a number?
    private var firstNumber: Double = 0       // First operand
    private var currentOperator: String?      // Current operator pressed (+, −, etc)
    
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


        if isTypingNumber {
            displayLabel.text! += number
        } else {
            displayLabel.text = number
            isTypingNumber = true
        }

        print("Updated displayLabel.text = \(displayLabel.text ?? "nil")")
    }

    @IBAction func operatorPressed(_ sender: UIButton) {
        guard let operation = sender.configuration?.title else { return }
            
        if operation == "AC" {
            displayLabel.text = "0"
            isTypingNumber = false
            firstNumber = 0
            currentOperator = nil
        } else if operation == "=" {
            guard let text = displayLabel.text,
                  let secondNumber = Double(text),
                  let op = currentOperator else { return }

            var result: Double = 0
            switch op {
            case "+": result = firstNumber + secondNumber
            case "−": result = firstNumber - secondNumber
            case "×": result = firstNumber * secondNumber
            case "÷": result = secondNumber != 0 ? firstNumber / secondNumber : 0
            default: break
            }

            displayLabel.text = formatResult(result)
            isTypingNumber = false
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
}
