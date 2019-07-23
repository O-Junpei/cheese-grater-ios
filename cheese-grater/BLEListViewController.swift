import UIKit
import CoreBluetooth

class BLEListViewController: UIViewController {
    
    private var tableView: UITableView!
    
    private var blueToothInfos: [BlueToothInfo] = []
    private var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(doClose))
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.rowHeight = 60
        view.addSubview(tableView)
                
        // CoreBluetoothを初期化および始動.
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    @objc func doClose() {
        dismiss(animated: true, completion: nil)
    }
}

extension BLEListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) cell was selected")
//        dismiss(animated: true, completion: nil)
        
        targetPeripheral = blueToothInfos[indexPath.row].peripheral
        centralManager.connect(blueToothInfos[indexPath.row].peripheral, options: nil)
    }
}

extension BLEListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blueToothInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: NSStringFromClass(UITableViewCell.self))

        let uuid = blueToothInfos[indexPath.row].uuid
        let name = blueToothInfos[indexPath.row].name
        // Cellに値を設定.
        cell.textLabel?.sizeToFit()
        cell.textLabel?.textColor = UIColor.red
        cell.textLabel?.text = name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        // Cellに値を設定(下).
        cell.detailTextLabel?.text = uuid.description
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        return cell
    }
}


extension BLEListViewController: CBCentralManagerDelegate{
    
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
        print("pheripheral.name: \(String(describing: peripheral.name))")
        print("advertisementData:\(advertisementData)")
        print("RSSI: \(RSSI)")
        print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)")
        let uuid = UUID(uuid: peripheral.identifier.uuid)
        
        var name = ""
        let kCBAdvDataLocalName = advertisementData["kCBAdvDataLocalName"] as? String
        if let dataLocalName = kCBAdvDataLocalName {
            name = dataLocalName.description
        } else {
            name = "no name"
        }
        
        let blueToothInfo = BlueToothInfo(uuid: uuid, name: name, peripheral: peripheral)
        blueToothInfos.append(blueToothInfo)
        blueToothInfos = blueToothInfos.unique
        
        tableView.reloadData()
    }
    
    /// Pheripheralに接続した時に呼ばれる。
    ///
    /// - Parameters:
    ///   - central: central description
    ///   - peripheral: peripheral description
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connect")
        
        // 遷移するViewを定義する.
        let secondViewController: SecondViewController = SecondViewController()
        secondViewController.setPeripheral(target: self.targetPeripheral)
        secondViewController.setCentralManager(manager: self.centralManager)
        secondViewController.searchService()

        // アニメーションを設定する.
        secondViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl

        // Viewの移動する.
        self.navigationController?.pushViewController(secondViewController, animated: true)

        // Scanを停止する.
        self.centralManager.stopScan()
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
