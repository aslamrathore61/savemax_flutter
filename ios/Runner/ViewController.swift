import UIKit

class ViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
    
        if #available(iOS 13.0, *) {
            return .darkContent // Use .darkContent if you want dark status bar text
        } else {
            return .default // Fallback for older versions
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the status bar background color is set
        if #available(iOS 13.0, *) {
            let statusBarFrame = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
            let statusBar = UIView(frame: statusBarFrame)
            statusBar.backgroundColor = UIColor(red: 0.91, green: 0.95, blue: 0.97, alpha: 1.00) // Your desired color
            self.view.addSubview(statusBar)
        } else {
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.backgroundColor = UIColor(red: 0.91, green: 0.95, blue: 0.97, alpha: 1.00) // Your desired color
            }
        }
    }
}
