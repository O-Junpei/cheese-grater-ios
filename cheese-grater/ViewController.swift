import UIKit
import CoreBluetooth
import SwiftyGif

final class ViewController: UIViewController {
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral!
    private var service: CBService!

    private var targetCharacteristic: CBCharacteristic!

    private var cheeseImageView: UIImageView = UIImageView()
    private var graterButton: UIButton!
    private var bleButton: UIButton!
    
    private var isGraterOn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundBlack")

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

        bleButton = UIButton()
        bleButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        bleButton.frame.size = CGSize(width: 80, height: 80)
        bleButton.center.x = width / 2
        bleButton.center.y = height - 80 - 40
        bleButton.setImage(UIImage(named: "ble-disconnected"), for: .normal)
        view.addSubview(bleButton)

        graterButton = UIButton()
        graterButton.addTarget(self, action: #selector(graterButtonTapped), for: .touchUpInside)
        graterButton.frame = CGRect(x: 20, y: 100, width: 100, height: 30)
        graterButton.setBackgroundImage(UIImage(named: "grater-off"), for: .normal)
        view.addSubview(graterButton)
        
        cheeseImageView = UIImageView(image: UIImage(named: "icon"))
        cheeseImageView.frame.size = CGSize(width: 100, height: 100)
        cheeseImageView.center = view.center
        view.addSubview(cheeseImageView)
    }

    func startCheeseAnimation() {
        do {
            cheeseImageView.removeFromSuperview()
            let gif = try UIImage(gifName: "Cheese.gif")
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
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    func sendData(data: String) {
        guard targetPeripheral != nil else {
            return
        }
        let data = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
        self.targetPeripheral.writeValue(data!, for: targetCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }

    @objc func on() {
        startCheeseAnimation()
        sendData(data: "1")
    }

    @objc func off() {
        stopCheeseAnimation()
        sendData(data: "0")
    }
    
    @objc func graterButtonTapped() {
        isGraterOn = !isGraterOn
        if isGraterOn {
            graterButton.setBackgroundImage(UIImage(named: "grater-on"), for: .normal)
        } else {
            graterButton.setBackgroundImage(UIImage(named: "grater-off"), for: .normal)
        }
    }
    
    func showAlert(title: String, message: String) {
        
    }
}

extension ViewController: CBCentralManagerDelegate {
    // CentralManager の状態が変わったら呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Bluetoothの電源がOff")
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
