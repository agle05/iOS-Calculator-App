import UIKit

class ViewController: UIViewController {

    @IBOutlet var allButtons: [UIButton]!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for button in allButtons {
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
        }
    }

    @IBAction func numberPressed(_ sender: UIButton) {
        if let number = sender.currentTitle {
            print("Number pressed: \(number)")
        }
    }

    @IBAction func operatorPressed(_ sender: UIButton) {
        if let operation = sender.currentTitle {
            print("Operator pressed: \(operation)")
        }
    }
}
