import UIKit
import CoreBluetooth

struct BlueToothInfo: Equatable {
    let uuid: UUID
    let name: String
    let peripheral: CBPeripheral
    
    static func == (lhs: BlueToothInfo, rhs: BlueToothInfo) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
