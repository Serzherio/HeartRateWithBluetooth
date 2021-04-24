import UIKit

class TableViewCell: UITableViewCell {

    var dateOfTrainLabel = UILabel()
    var duringTimeLabel = UILabel()
    var heartRateLabel = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.dateOfTrainLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 400, height: 30))
        self.duringTimeLabel = UILabel(frame: CGRect(x: 100, y: 20, width: 400, height: 30))
        self.heartRateLabel = UILabel(frame: CGRect(x: 100, y: 40, width: 400, height: 30))
        self.dateOfTrainLabel.textColor = UIColor(red: 70, green: 150, blue: 153)
        self.duringTimeLabel.textColor = .systemPink
        self.heartRateLabel.textColor = .purple
        
        self.addSubview(dateOfTrainLabel)
        self.addSubview(duringTimeLabel)
        self.addSubview(heartRateLabel)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
