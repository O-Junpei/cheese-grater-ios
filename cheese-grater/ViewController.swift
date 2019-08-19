import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral!
    var service: CBService!

    var targetCharacteristic: CBCharacteristic!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let connectButton = UIButton()
        connectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        connectButton.frame = CGRect(x: 20, y: 100, width: 100, height: 100)
        connectButton.setTitle("Connect", for: .normal)
        connectButton.backgroundColor = .red
        view.addSubview(connectButton)
        
        let disconnectButton = UIButton()
        disconnectButton.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
        disconnectButton.frame = CGRect(x: 200, y: 100, width: 100, height: 100)
        disconnectButton.setTitle("Connect", for: .normal)
        disconnectButton.backgroundColor = .red
        view.addSubview(disconnectButton)
        
        let onButton = UIButton()
        onButton.addTarget(self, action: #selector(on), for: .touchUpInside)
        onButton.frame = CGRect(x: 20, y: 300, width: 100, height: 100)
        onButton.setTitle("On", for: .normal)
        onButton.backgroundColor = .red
        view.addSubview(onButton)
        
        let offButton = UIButton()
        offButton.addTarget(self, action: #selector(off), for: .touchUpInside)
        offButton.frame = CGRect(x: 200, y: 300, width: 100, height: 100)
        offButton.setTitle("Off", for: .normal)
        offButton.backgroundColor = .red
        view.addSubview(offButton)
    }
    
    @objc func connect() {
//        let bleListViewController = BLEListViewController()
//        let navigationController = UINavigationController(rootViewController: bleListViewController)
//        present(navigationController, animated: true, completion: nil)
        
            centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    @objc func disconnect() {
        
    }
    
    @objc func on() {
        
        let data = "1".data(using: String.Encoding.utf8, allowLossyConversion:true)
        self.targetPeripheral.writeValue(data!, for: targetCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
    }
    
    @objc func off() {
        
        let data = "0".data(using: String.Encoding.utf8, allowLossyConversion:true)
        self.targetPeripheral.writeValue(data!, for: targetCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
}

extension ViewController: CBCentralManagerDelegate{
    
    /// Central Managerの状態がかわったら呼び出される。
    ///
    /// - Parameter central: Central manager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state \(central.state)")
        
        switch central.state {
        case .poweredOff:
            print("Bluetoothの電源がOff")
        case .poweredOn:
            print("Bluetoothの電源はOn")
            // BLEデバイスの検出を開始.
            centralManager.scanForPeripherals(withServices: nil)
        case .resetting:
            print("レスティング状態")
        case .unauthorized:
            print("非認証状態")
        case .unknown:
            print("不明")
        case .unsupported:
            print("非対応")
        @unknown default:
            fatalError()
        }
    }
    
    /// PheripheralのScanが成功したら呼び出される。
    ///
    /// - Parameters:
    ///   - central: central description
    ///   - peripheral: peripheral description
    ///   - advertisementData: advertisementData description
    ///   - RSSI: RSSI description
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
//        print("pheripheral.name: \(String(describing: peripheral.name))")
//        print("advertisementData:\(advertisementData)")
//        print("RSSI: \(RSSI)")
//        print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)")
//        let uuid = UUID(uuid: peripheral.identifier.uuid)
        
//        var name = ""
//        let kCBAdvDataLocalName = advertisementData["kCBAdvDataLocalName"] as? String
//        if let dataLocalName = kCBAdvDataLocalName {
//            name = dataLocalName.description
//        } else {
//            name = "no name"
//        }
        
        
        if peripheral.name?.contains("ESP") ?? false {
            print("ESPきたぞ！！！")
            print("pheripheral.name: \(String(describing: peripheral.name))")
            print("advertisementData:\(advertisementData)")
            print("RSSI: \(RSSI)")
            print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)")
            
            targetPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
        
        
        
//        let blueToothInfo = BlueToothInfo(uuid: uuid, name: name, peripheral: peripheral)
//        blueToothInfos.append(blueToothInfo)
//        blueToothInfos = blueToothInfos.unique
//
//        tableView.reloadData()
    }
    
    
    func connectzzzz() {
        
    }
    
    
    
    
    /// Pheripheralに接続した時に呼ばれる。
    ///
    /// - Parameters:
    ///   - central: central description
    ///   - peripheral: peripheral description
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connect")
        
        // 遷移するViewを定義する.
//        let secondViewController: SecondViewController = SecondViewController()
//        secondViewController.setPeripheral(target: self.targetPeripheral)
//        secondViewController.setCentralManager(manager: self.centralManager)
//        secondViewController.searchService()
        
//        // アニメーションを設定する.
//        secondViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
//
//        // Viewの移動する.
//        self.navigationController?.pushViewController(secondViewController, animated: true)
//
        // Scanを停止する.
        centralManager.stopScan()
        
        self.targetPeripheral.delegate = self
        self.targetPeripheral.discoverServices(nil)
    }
    
    /// Pheripheralの接続に失敗した時に呼ばれる。
    ///
    /// - Parameters:
    ///   - central: central description
    ///   - peripheral: peripheral description
    ///   - error: error description
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            print("Error: \(e.localizedDescription)")
            return
        }
        print("not connnect")
    }
}






extension ViewController: CBPeripheralDelegate{
    
    /// Serviceの検索が終わったら呼び出される
    ///
    /// - Parameters:
    ///   - peripheral: peripheral description
    ///   - error: error description
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error {
            print("Error: \(e.localizedDescription)")
            return
        }
        
        print("didDiscoverServices")
        self.service = peripheral.services?.first
        
        self.targetPeripheral.discoverCharacteristics(nil, for: self.service)

    }
    
    
    /// Characteristicの検索が終わったら呼び出される
    ///
    /// - Parameters:
    ///   - peripheral: peripheral description
    ///   - service: service description
    ///   - error: error description
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsForService")
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if isWrite(characteristic: characteristic) {
                self.targetCharacteristic = characteristic
            }
        }
    }
 
    
    /// Write可能か
    ///
    /// - Parameter characteristic: characteristic description
    /// - Returns: return value description
    func isWrite(characteristic: CBCharacteristic) -> Bool{
        if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
            return true
        }
        return false
    }
    
}
