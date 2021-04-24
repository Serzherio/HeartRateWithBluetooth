import Foundation
import RealmSwift

class Train: Object {
    
    @objc dynamic var dateOfTrain : Date?
    @objc dynamic var duringTime : String?
    dynamic var heartRate = List<Int>()
    
    
    convenience init(date : Date?, during: String?) {
        
        self.init()
        self.dateOfTrain = date
        self.duringTime = during
    }
}

