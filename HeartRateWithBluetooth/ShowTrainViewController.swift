import UIKit
import Charts

class ShowTrainViewController: UIViewController {

    @IBOutlet weak var barChatView: BarChartView!
    var months: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
  
    }
  
    
    
}
