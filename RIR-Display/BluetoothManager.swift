//
//  BluetoothManager.swift
//  RIR-Display
//
//  Created by Kevin Ramos on 11/28/23.
//

import Foundation
import CoreBluetooth

let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")

protocol OnDidDiscoverPeripheralDelegate: AnyObject {
    func onDidDiscoverPeripheral()
}


class BluetoothManager: NSObject {
    static let shared = BluetoothManager()
    
    static weak var onDidDiscoverPeripheralDelegate: OnDidDiscoverPeripheralDelegate?
    
    private var centralManager: CBCentralManager?
    @Published var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    
    var heartRatePeripheral: CBPeripheral!
    
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    func SetHeartRatePeripheral(index: Int) {
        heartRatePeripheral = peripherals[index]
        centralManager?.stopScan()
        centralManager?.connect(heartRatePeripheral)
        heartRatePeripheral.delegate = self
    }
}


extension BluetoothManager: CBCentralManagerDelegate {
    // Bluetooth state update check
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            centralManager?.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        @unknown default:
            fatalError()
        }
    }
    
    // Discovering Devices
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            print(peripheral)
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "Unnamed Device")
//            tableView.reloadData() TODO
            BluetoothManager.onDidDiscoverPeripheralDelegate?.onDidDiscoverPeripheral()
            print("🍏 Updated Device List")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("🍏 Connected!")
//        heartRatePeripheral.discoverServices(nil)  Will allow for battery display later
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
        
    }
    
    
}

extension BluetoothManager: CBPeripheralDelegate {
    // Discover services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // Handles reading?
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
      guard let characteristics = service.characteristics else { return }

      for characteristic in characteristics {
          print(characteristic)
          if characteristic.properties.contains(.read) {
              print("\(characteristic.uuid): properties contains .read")
              peripheral.readValue(for: characteristic)
          }
          if characteristic.properties.contains(.notify) {
              print("\(characteristic.uuid): properties contains .notify")
              peripheral.setNotifyValue(true, for: characteristic)
          }
      }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
      switch characteristic.uuid {
        case bodySensorLocationCharacteristicCBUUID:
          let bodySensorLocation = bodyLocation(from: characteristic)
//          bodySensorLocationLabel.text = bodySensorLocation
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
//          print("BPM", bpm)
          MainViewController.MainView.onHeartRateReceivedDelegate?.onHeartRateReceived(bpm: bpm)

        default:
          print("Unhandled Characteristic UUID: \(characteristic.uuid)")
      }
    }
    
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
      guard let characteristicData = characteristic.value,
        let byte = characteristicData.first else { return "Error" }

      switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
          return "Reserved for future use"
      }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
      guard let characteristicData = characteristic.value else { return -1 }
      let byteArray = [UInt8](characteristicData)

      let firstBitValue = byteArray[0] & 0x01
      if firstBitValue == 0 {
        // Heart Rate Value Format is in the 2nd byte
        return Int(byteArray[1])
      } else {
        // Heart Rate Value Format is in the 2nd and 3rd bytes
        return (Int(byteArray[1]) << 8) + Int(byteArray[2])
      }
    }
}
