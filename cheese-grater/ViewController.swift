import UIKit
import CoreBluetooth
import SwiftyGif

final class ViewController: UIViewController {
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral!
    private var service: CBService!

    private var targetCharacteristic: CBCharacteristic!

    private var cheeseGraterView: CheeseGraterView!
    private var graterButton: UIButton!
    private var bleButton: UIButton!
    
    private var isGraterOn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundBlack")

        let width = view.bounds.width
        let height = view.bounds.height

        bleButton = UIButton()
        bleButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        bleButton.frame.size = CGSize(width: 80, height: 80)
        bleButton.center.x = width / 2
        bleButton.center.y = height - 80 - 40
        bleButton.setImage(UIImage(named: "ble-disconnected"), for: .normal)
        view.addSubview(bleButton)

        graterButton = UIButton()
        graterButton.addTarget(self, action: #selector(graterButtonTapped), for: .touchUpInside)
        graterButton.frame.size = CGSize(width: 202, height: 69)
        graterButton.center.x = width / 2
        graterButton.center.y = 60
        graterButton.setBackgroundImage(UIImage(named: "grater-off"), for: .normal)
        view.addSubview(graterButton)
        
        cheeseGraterView = CheeseGraterView()
        cheeseGraterView.frame.size = CGSize(width: 142, height: 279)
        cheeseGraterView.center = view.center
        view.addSubview(cheeseGraterView)
    }

    @objc func connect() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    func sendData(data: String) {
        let data = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
        self.targetPeripheral.writeValue(data!, for: targetCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    @objc func graterButtonTapped() {
//        guard targetPeripheral != nil && targetCharacteristic != nil else {
//            showAlert(title: "Error", message: "削り機が未接続です")
//            return
//        }
        
        isGraterOn = !isGraterOn
        if isGraterOn {
            graterButton.setBackgroundImage(UIImage(named: "grater-on"), for: .normal)
            cheeseGraterView.startAnimation()
//            sendData(data: "1")
        } else {
            graterButton.setBackgroundImage(UIImage(named: "grater-off"), for: .normal)
            cheeseGraterView.stopAnimation()
//            sendData(data: "0")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController( title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: CBCentralManagerDelegate {
    // CentralManager の状態が変わったら呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            showAlert(title: "Error", message: "Bluetoothの電源がOff")
        case .poweredOn:
            print("Bluetoothの電源はOn")
            // BLEデバイスの検出を開始
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

    // デバイスの検出が完了したら呼ばれる
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if peripheral.name?.contains("ESP") ?? false {
            print("ESPきたぞ！！！")
            print("pheripheral.name: \(String(describing: peripheral.name))")
            print("advertisementData:\(advertisementData)")
            print("RSSI: \(RSSI)")
            print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)")

            targetPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }

    // デバイスに接続した時に呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
        targetPeripheral.delegate = self
        targetPeripheral.discoverServices(nil)
    }

    // デバイスの接続に失敗したときに呼ばれる
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            print("Error: \(e.localizedDescription)")
            return
        }
        print("not connnect")
    }
}


extension ViewController: CBPeripheralDelegate {
    // Serviceの検索が終わったら呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error {
            print("Error: \(e.localizedDescription)")
            return
        }

        // 作成したデバイスにサービスは一つしかないので一つ目を取得
        service = peripheral.services?.first
        targetPeripheral.discoverCharacteristics(nil, for: self.service)
    }

    // Characteristicの検索が終わったら呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsForService")

        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            if isWrite(characteristic: characteristic) {
                self.targetCharacteristic = characteristic
                self.bleButton.setBackgroundImage(UIImage(named: "ble-connected"), for: .normal)
            }
        }
    }

    // Write可能か
    func isWrite(characteristic: CBCharacteristic) -> Bool {
        if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
            return true
        }
        return false
    }
}
