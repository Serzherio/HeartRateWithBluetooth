import UIKit
import CoreBluetooth
import NeumorphismKit

class TrainViewController: UIViewController {
    
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
    
    
    
    @IBOutlet weak var arrowImage: UIImageView!
    
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var deviceStatusLabel: NeumorphismLabel!
    @IBOutlet weak var startTrainButton: NeumorphismButton!
    @IBOutlet weak var stopTrainButton: NeumorphismButton!
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    
    
    var startTime = TimeInterval()
    var heartReateStorage : [Int] = []
    var duringTime = TimeInterval()
    
    // Сканирует, обнаруживает, подключается к перифирийным устройствам
    var centralManager: CBCentralManager!
    
    //  Удаленное перифирийное устройство
    var heartRatePeripheral: CBPeripheral!
    var degree = CGFloat(Double.pi/180)
    var startTraining : Bool = false
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        stopTrainButton.isHidden = true
        heartRateLabel.isHidden = true
        timerStackView.isHidden = true
        
        deviceStatusLabel.isConvex = false
        deviceStatusLabel.textColor = .gray
        deviceStatusLabel.text = "Пульсометр отключен"
        
        setUpBGImage()
        
        //      Инициализация с присвоением делегата и определением очереди (главная очередь)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        heartRateLabel.font = UIFont.monospacedDigitSystemFont(ofSize: heartRateLabel.font!.pointSize, weight: .regular)
        
        
        
    }
    
    
    
    
    @IBAction func startTrainAction(_ sender: Any) {
        startTrainButton.isHidden = true
        stopTrainButton.isHidden = false
        timerStackView.isHidden = false
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
        
        
    }
    
    
    
    
    @IBAction func stopTrainAction(_ sender: Any) {
        startTrainButton.isHidden = false
        stopTrainButton.isHidden = true
        
        hourLabel.text = "00:"
        minuteLabel.text = "00:"
        secLabel.text = "00"
        
        timer.invalidate()
        
        let dateNow = Date()
    
        let duringIntSec = UInt8(duringTime)
        let duringIntMin = UInt8(duringTime / 60)
        let duringSec = String(duringIntSec)
        let duringMin = String(duringIntMin)
        
        let train = Train(date: dateNow, during: duringMin)
        train.heartRate.append(objectsIn: heartReateStorage)
        StorageManager.saveObject(train)
        
        duringTime = 0
        heartReateStorage = []
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
    }
    
    @objc func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        var elapsedTime = currentTime - startTime
        duringTime = elapsedTime
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        hourLabel.text = "\(strMinutes):"
        minuteLabel.text = "\(strSeconds):"
        secLabel.text = "\(strFraction)"
    }
    
    func setUpBGImage() {
        let image = UIImage(named: "Background")
        self.view.backgroundColor = UIColor(patternImage: image!)
    }
    
    func onHeartRateReceived(_ heartRate: Int) {
        arrowImage.isHidden = false
        heartRateLabel.isHidden = false
        BPMtoDegree(heartRate: heartRate)
        heartRateLabel.text = String(heartRate)
        if startTraining == true {
            heartReateStorage.append(heartRate)
        }
    }
    
    func BPMtoDegree(heartRate: Int) {
        var angle: CGFloat
        if heartRate < 70 {
            angle = CGFloat( Double(70-140) * (Double.pi/80) )
        } else if heartRate > 210 {
            angle = CGFloat( Double(210-140) * (Double.pi/80) )
        } else {
            angle = CGFloat( Double(heartRate-140) * (Double.pi/80) )
        }
        rotateImage(rotationAngle: angle)
        
        
    }
    
    
    
    
    func rotateImage(rotationAngle: CGFloat) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: { [self] () -> Void in
            setAnchorPoint(CGPoint(x: 0.5, y: 0.86), for: arrowImage)
            self.arrowImage.transform = CGAffineTransform(rotationAngle: rotationAngle)
        })
    }
    
    func setAnchorPoint(_ anchorPoint: CGPoint, for view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        var position: CGPoint = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
}



// MARK:- Протокол для обнаружения и управления перефирийными устройствами
extension TrainViewController: CBCentralManagerDelegate {
    
    
    //  Обязательный метод протокола для проверки состояния центрального менеджера (вызывается ЦМ автоматически для проверки состояния)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print ("central.state is unknown")
        case .resetting:
            print ("central.state is resetting")
        case .unsupported:
            print ("central.state is unsupported")
        case .unauthorized:
            print ("central.state is unauthorized")
        case .poweredOff:
            print ("central.state is poweredOff")
        case .poweredOn:
            print ("central.state is poweredOn")
            
            //          Сканирование на наличие перифирийных устройств с заданными параметрами перефирии, где
            //          CBUUID  - универсальный идентификатор, определенный стандартами Bluetooth
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        }
    }
    
    //  Сообщает делегату, что центральный менеджер отключен от перифирийного устройства
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //      Обновление интерфейса при потери соединения
        //        arrowImage.isHidden = true
        heartRateLabel.isHidden = true
        deviceStatusLabel.isConvex = false
        deviceStatusLabel.textColor = .gray
        deviceStatusLabel.text = "Пульсометр отключен"
        
        //      Попытаемся подключиться заново
        centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID], options: nil)
    }
    
    
    //  Сообщает делегату, что центральный менеджер обнаружил перифирийное устройство во время сканирования
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //      Перифирийное устройство обнаружено
        heartRatePeripheral = peripheral
        
        //      Подписаем под протокол CBPeripheralDelegate, предоставляющий обновленную информацию об использовании служб перифирийного устройства
        heartRatePeripheral.delegate = self
        
        //      Прекращение происка перифирийных устройств
        centralManager.stopScan()
        
        //      Установка локального соединения с перифирийным устройством
        centralManager.connect(heartRatePeripheral)
    }
    
    //  Сообщает делегату, что центральный менеджер был подключен к перифирийному устройству
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //      Обнаружение указанные службы перифирийного устройства
        //      Возвращает только те службы, которые соответствуют предоставленным UUID для поиска
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
        
        //      Обновление статуса пользовательского интерфейса о подключении устройства
        deviceStatusLabel.isConvex = true
        deviceStatusLabel.textColor = .white
        deviceStatusLabel.text = "Пульсометр подключен"
    }
    
}



//MARK:- Протокол, предоставляющий обновленную информацию об использовании служб перифирийного устройства
extension TrainViewController: CBPeripheralDelegate {
    
    //  Сообщает делегату, что обнаружение перифирийных служб выполнено успешно
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        //      Получаем доступ к перифирийным службам через свойство перифирийного service устройства
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    //  Сообщают делегату, что перифирийное устройство нашло зарактеристики для службы
    //  Peripheral - перифирийное устройство, предоставляющее эту информацию
    //  Service - сервис, к которому относятся характеристики
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //      Доступ к службам можно получить через свойство службы characteristic
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                //              Извлекает значение заданной характеристики
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                //              Устанавливает значение уведомления для характеристики
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    
    //  Сообщает делегату, что полученние значение указанной характеристики прошло успешно, или значение характеристики изменилось
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        //      Возможные значения характеристик
        switch characteristic.uuid {
        
        //        case bodySensorLocationCharacteristicCBUUID:
        //            let bodySensorLocation = bodyLocation(from: characteristic)
        //            bodySensorLocationLabel.text = bodySensorLocation
        
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
            
        default:
            break
        }
    }
    
    
    //  Характеристика получения ЧСС для различных форматов получаемой информации (2 байта/1 байт)
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            return Int(byteArray[1])
        } else {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    
    
}


