//
//  MainViewController.swift
//  RIR-Display
//
//  Created by Kevin Ramos on 11/28/23.
//

import UIKit
import CoreBluetooth
import Charts

protocol OnHeartRateReceivedDelegate: AnyObject {
    func onHeartRateReceived(bpm: Int)
}

class MainViewController: UIViewController, OnHeartRateReceivedDelegate {
    
    @IBOutlet weak var BPMLabel: UILabel!
    @IBOutlet weak var RPELabel: UILabel!
    
    @IBOutlet weak var maxField: UITextField!
    @IBOutlet weak var restField: UITextField!
    @IBOutlet weak var KBToolbar: UIToolbar!
    
    
    static let MainView = MainViewController.self
    
    static weak var onHeartRateReceivedDelegate: OnHeartRateReceivedDelegate?
    
    var bpm: Int = 0
    var restBPM: Int = 60
    var maxBPM: Int = 140
    var repsInReserve: Int = 10
    var ratedPercievedExertion: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        MainViewController.onHeartRateReceivedDelegate = self
        
        maxField.inputAccessoryView = KBToolbar
        restField.inputAccessoryView = KBToolbar
    }
    
    
    @IBAction func MaxFieldEditEnd(_ sender: Any) {
        let value = Int(maxField.text ?? "120")
        maxBPM = max(60, value!)
        print("🍏 Update Max", String(value ?? maxBPM))
    }
    
    @IBAction func RestFieldEditEnd(_ sender: Any) {
        let value = Int(restField.text ?? "120")
        restBPM = max(40, value!)
        print("🍏 Update Rest", String(value ?? restBPM))
    }
    
    
    @IBAction func didTapToolbarDone(_ sender: Any) {
        view.endEditing(true)
        resignFirstResponder()
    }
    
    func onHeartRateReceived(bpm: Int) {
        self.bpm = bpm
//        calculateRIR()
        calculateRPE()
        RPELabel.text = String(ratedPercievedExertion)
        BPMLabel.text = String(bpm)
        print("🍏", bpm, "BPM | RIR", repsInReserve)
        
    }
    
    private func calculateRIR() {
        let denom = (maxBPM - restBPM) > 0 ? (maxBPM - restBPM) : 1
        let rawPercent = Float((bpm - restBPM) / denom)
        ratedPercievedExertion = 10 * rawPercent
        repsInReserve = 10 - Int(floor(rawPercent))
    }
    
    private func calculateRPE() {
        ratedPercievedExertion = -0.998 + (0.0935 * Float(bpm))
    }
}
