//
//  MainViewController.swift
//  RIR-Display
//
//  Created by Kevin Ramos on 11/28/23.
//

import UIKit
import CoreBluetooth

protocol OnHeartRateReceivedDelegate: AnyObject {
    func onHeartRateReceived(bpm: Int)
}

class MainViewController: UIViewController, OnHeartRateReceivedDelegate {
    
    @IBOutlet weak var BPMLabel: UILabel!
    static let MainView = MainViewController.self
    
    static weak var onHeartRateReceivedDelegate: OnHeartRateReceivedDelegate?
    
    var bpm: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        MainViewController.onHeartRateReceivedDelegate = self
    }
    
    func onHeartRateReceived(bpm: Int) {
        print("🍏", bpm, " BPM")
        self.bpm = bpm
        BPMLabel.text = String(bpm)
    }
    
    
    @IBAction func didTapConnectButton(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // MARK: - Pass the Central Manager to the View

        // Get access to the detail view controller via the segue's destination. (guard to unwrap the optional)
        guard let bluetoothViewController = segue.destination as? BluetoothViewController else { return }
        
    }
}
