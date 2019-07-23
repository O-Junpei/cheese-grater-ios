import UIKit

class ViewController: UIViewController {

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
        let bleListViewController = BLEListViewController()
        let navigationController = UINavigationController(rootViewController: bleListViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func disconnect() {
        
    }
    
    @objc func on() {
        
    }
    
    @objc func off() {
        
    }
}
