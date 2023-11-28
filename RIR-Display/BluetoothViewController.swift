//
//  BluetoothViewController.swift
//  RIR-Display
//
//  Created by Kevin Ramos on 11/27/23.
//

import UIKit
import CoreBluetooth



class BluetoothViewController: ViewController, OnDidDiscoverPeripheralDelegate {
//    var centralManager: CBCentralManager?
//    private var peripherals: [CBPeripheral] = []
//    @Published var peripheralNames: [String] = []
    
//    var heartRatePeripheral: CBPeripheral!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        
        tableView.dataSource = self
        tableView.delegate = self
        BluetoothManager.onDidDiscoverPeripheralDelegate = self
    }

    func onDidDiscoverPeripheral() {
        print("🍏 Reload Table")
        tableView.reloadData()
    }
}

extension BluetoothViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🍏peripherals: ", BluetoothManager.shared.peripherals.count)
        return BluetoothManager.shared.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeripheralCell", for: indexPath) as! PeripheralCell

        let name = BluetoothManager.shared.peripheralNames[indexPath.row]
        cell.configure(peripheralName: name)
        return cell
        
    }
}

extension BluetoothViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("🍏", BluetoothManager.shared.peripheralNames[indexPath.row], " was selected.")
        
        BluetoothManager.shared.SetHeartRatePeripheral(index: indexPath.row)
        dismiss(animated: true)
    }
}
