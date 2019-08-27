import UIKit
import CoreBluetooth
import SwiftyGif

final class ViewController: UIViewController {
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral!
    private var service: CBService!
    private var cheeseImageView: UIImageView = UIImageView()

    var targetCharacteristic: CBCharacteristic!


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray

        let width = view.bounds.width
        let height = view.bounds.height

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

        let connectButton = UIButton()
        connectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        connectButton.frame.size = CGSize(width: 80, height: 80)
        connectButton.center.x = width / 2
        connectButton.center.y = height - 80 - 40
        connectButton.setTitle("Connect", for: .normal)
        connectButton.backgroundColor = .red
        view.addSubview(connectButton)

        cheeseImageView = UIImageView(image: UIImage(named: "icon"))
        cheeseImageView.frame.size = CGSize(width: 100, height: 100)
        cheeseImageView.center = view.center
        view.addSubview(cheeseImageView)
    }

    func startCheeseAnimation() {
        do {
            cheeseImageView.removeFromSuperview()
            let gif = try UIImage(gifName: "b.gif")
            cheeseImageView = UIImageView(gifImage: gif, loopCount: -1)
            cheeseImageView.frame.size = CGSize(width: 100, height: 100)
            cheeseImageView.center = view.center
            view.addSubview(cheeseImageView)
        } catch {
            print(error)
        }
    }

    func stopCheeseAnimation() {
        cheeseImageView.removeFromSuperview()
        cheeseImageView = UIImageView(image: UIImage(named: "icon"))
        cheeseImageView.frame.size = CGSize(width: 100, height: 100)
        cheeseImageView.center = view.center
        view.addSubview(cheeseImageView)
    }


    @objc func connect() {
//        let bleListViewController = BLEListViewController()
//        let navigationController = UINavigationController(rootViewController: bleListViewController)
//        present(navigationController, animated: true, completion: nil)

        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    func sendData(data: String) {
        
    }

    @objc func on() {
        startCheeseAnimation()
        
        guard targetPeripheral != nil else {
            return
        }
        let data = "1".data(using: String.Encoding.utf8, allowLossyConversion: true)
        self.targetPeripheral.writeValue(data!, for: targetCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }

    @objc func off() {
        stopCheeseAnimation()
        guard targetPeripheral != nil else {
            return
        }
        let data = "0".data(using: String.Encoding.utf8, allowLossyConversion: true)
        self.targetPeripheral.writeValue(data!, for: targetCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
}

extension ViewController: CBCentralManagerDelegate {

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






extension ViewController: CBPeripheralDelegate {

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
    func isWrite(characteristic: CBCharacteristic) -> Bool {
        if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
            return true
        }
        return false
    }
}
