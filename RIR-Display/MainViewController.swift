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

enum DataMode {
    case stats
    case workout
}

class MainViewController: UIViewController, OnHeartRateReceivedDelegate {
    
    static let MainView = MainViewController.self
    static weak var onHeartRateReceivedDelegate: OnHeartRateReceivedDelegate?
    
    @IBOutlet weak var BPMLabel: UILabel!
    @IBOutlet weak var RPELabel: UILabel!
    @IBOutlet weak var RPEDecLabel: UILabel!
    
    @IBOutlet weak var maxField: UITextField!
    @IBOutlet weak var restField: UITextField!
    @IBOutlet weak var KBToolbar: UIToolbar!
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    
    var barChart = BarChartView()

    
    var bpm: Int = 0
    var restBPM: Int = 60
    var maxBPM: Int = 140
    
    var customMaxBPM: Int = 200
    var ratedPercievedExertion: Float = 1
    var maxRPE: Float = 1
    
    var hrData: [Int] = []
    var hrMaxLen: Int = 60
    var curGraphIndex: Int = 60
    
    var mode: DataMode = DataMode.stats
    
    var graphEntries: [BarChartDataEntry] = [BarChartDataEntry]()
    
    var workoutScreenTime: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        MainViewController.onHeartRateReceivedDelegate = self
        
        maxField.inputAccessoryView = KBToolbar
        restField.inputAccessoryView = KBToolbar
        
        // Initialize array
        for x in 0..<60 {
            hrData.append(60)
            graphEntries.append(BarChartDataEntry(x:Double(x),y:Double(60)))
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        barChart.frame = CGRect(x:5,y:5, width: self.view.frame.size.width-10, height: 115)
        
        graphView.addSubview(barChart)
        
        let set = BarChartDataSet(entries: graphEntries)
        
        set.colors = [UIColor(red: 235/255, green: 85/255, blue: 70/255, alpha: 1)]
        let data = BarChartData(dataSet: set)
        data.setDrawValues(false)
    
        barChart.xAxis.enabled = false
        barChart.legend.enabled = false
        barChart.leftAxis.axisMaximum = 180
        barChart.leftAxis.axisMinimum = 60
        barChart.rightAxis.axisMaximum = 180
        barChart.rightAxis.axisMinimum = 60
        barChart.leftAxis.enabled = false
        barChart.highlightPerTapEnabled = false
        barChart.highlightPerDragEnabled = false
        
        barChart.data = data
    }
    
    
    @IBAction func MaxFieldEditEnd(_ sender: Any) {
        if let value = Int(maxField.text ?? "120") {
            customMaxBPM = max(60, value)
        } else {
            maxField.text = String(customMaxBPM)
        }
        print("🍏 Update Max", String(customMaxBPM))
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
        calculateRPE()
        
        // Update Min Max BPMs
        (restBPM, maxBPM) = hrData.minAndMax() ?? (restBPM, maxBPM)
        
        
        // Reset Max RPE if on workout screen for 5s
        // and count
        if (mode == DataMode.workout) {
            UpdateRPELabels(RPE: ratedPercievedExertion)
            
            workoutScreenTime += 1
            
            if (workoutScreenTime > 3){
                maxRPE = max(maxRPE, ratedPercievedExertion)
            } else  if (workoutScreenTime == 3) {
                maxRPE = ratedPercievedExertion
            }
        } else {
            maxRPE = max(maxRPE, ratedPercievedExertion)
            UpdateRPELabels(RPE: maxRPE)
            maxField.text = String(maxBPM)
        }
        
        // Update Labels
        BPMLabel.text = String(bpm)
        restField.text = String(restBPM)
        
        print("🍏", bpm, "BPM | RPE", ratedPercievedExertion)
        AddHRtoData(bpm: bpm)
    }
    
    private func UpdateRPELabels(RPE: Float) {
        // Separate whole value from decimal
        let wholeValue = Int(floor(RPE))
        let decValue: Float = floor((RPE - Float(wholeValue)) * 100) / Float(100)
        let decString = String(format: "%.2f", decValue).replacingOccurrences(of: "^\\d*\\.", with: ".", options: .regularExpression)
        
        
        // Update Labels
        RPELabel.text = String(wholeValue)
        RPEDecLabel.text = String(decString)
    }
    
    
    // Switch Workout Modes
    @IBAction func didTapModeControl(_ sender: UISegmentedControl) {
        calculateRPE()
        switch(sender.selectedSegmentIndex) {
        case 0:
            mode = DataMode.stats
            maxField.text = String(maxBPM)
            UpdateRPELabels(RPE: maxRPE)
        case 1:
            mode = DataMode.workout
            maxField.text = String(customMaxBPM)
            workoutScreenTime = 0
            UpdateRPELabels(RPE: ratedPercievedExertion)
        default:
            break
        }
        
        
    }
    
    private func calculateRPE() {
        ratedPercievedExertion = 1 + Float(10.0 / Float(customMaxBPM - 60)) * Float(bpm - 60)
        
        // Clamp RPE between 0 and 20
        ratedPercievedExertion = ratedPercievedExertion.clamped(to: 0.0...20.0)
    }
    
    
    private func AddHRtoData(bpm: Int) {
        hrData.append(bpm)
        curGraphIndex += 1
        
        if (hrData.count >= hrMaxLen) {
            hrData.remove(at: 0)
        }
        
        // Update Bar graph
        graphEntries.append(BarChartDataEntry(x: Double(curGraphIndex), y: Double(bpm)))
        
        if (graphEntries.count >= hrMaxLen) {
            graphEntries.remove(at: 0)
        }
        
        let set = BarChartDataSet(entries: graphEntries)
        
        set.colors = [UIColor(red: 235/255, green: 85/255, blue: 70/255, alpha: 1)]
        let data = BarChartData(dataSet: set)
        data.setDrawValues(false)
        barChart.data = data
        
        // Notify the chart that the data has changed and needs to be refreshed
        barChart.notifyDataSetChanged()
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
