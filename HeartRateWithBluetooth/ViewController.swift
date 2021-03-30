import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
    
    
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var bodySensorLocationLabel: UILabel!
    @IBOutlet weak var deviceStatus: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var heartReateStorage : [Int] = []
    
// Сканирует, обнаруживает, подключается к перифирийным устройствам
    var centralManager: CBCentralManager!

//  Удаленное перифирийное устройство
    var heartRatePeripheral: CBPeripheral!
    var degree = CGFloat(Double.pi/180)
    var degree1 = CGFloat(Double.pi)
    var startTraining : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startButton.layer.cornerRadius = 10
        stopButton.layer.cornerRadius = 10
        stopButton.isHidden = true
        arrowImage.isHidden = true
        heartRateLabel.isHidden = true
        deviceStatus.text = "подключение..."
        deviceStatus.textColor = .red
        
        
//      Инициализация с присвоением делегата и определением очереди (главная очередь)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        heartRateLabel.font = UIFont.monospacedDigitSystemFont(ofSize: heartRateLabel.font!.pointSize, weight: .regular)
    }
    
    
    @IBAction func startTrainingAction(_ sender: Any) {
        startButton.isHidden = true
        stopButton.isHidden = false
        startTraining = true
    }
    
    @IBAction func stopTrainingAction(_ sender: Any) {
        startButton.isHidden = false
        stopButton.isHidden = true
        startTraining = false
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
extension ViewController: CBCentralManagerDelegate {
    
    
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
        print("Устройство \(peripheral) было отключено по причине: \(error)")
        
//      Обновление интерфейса при потери соединения
        arrowImage.isHidden = true
        heartRateLabel.isHidden = true
        deviceStatus.text = "подключение..."
        deviceStatus.textColor = .red
        
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
        deviceStatus.text = "подключено"
        deviceStatus.textColor = UIColor.green
    
//      Обнаружение указанные службы перифирийного устройства
//      Возвращает только те службы, которые соответствуют предоставленным UUID для поиска
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    }
    
}



//MARK:- Протокол, предоставляющий обновленную информацию об использовании служб перифирийного устройства
extension ViewController: CBPeripheralDelegate {
    
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
        
        case bodySensorLocationCharacteristicCBUUID:
            let bodySensorLocation = bodyLocation(from: characteristic)
            bodySensorLocationLabel.text = bodySensorLocation
            
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
            
        default:
            break
        }
    }
    
//  Характеристика положения датчика ЧСС на теле
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
              let byte = characteristicData.first else { return "Error" }
        switch byte {
        case 0: return "Другое"
        case 1: return "Грудь"
        case 2: return "Запястье"
        case 3: return "Палец"
        case 4: return "Ладонь"
        case 5: return "Мочка уха"
        case 6: return "Нога"
        default:
            return "Резерв"
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


