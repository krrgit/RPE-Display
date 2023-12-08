//
//  MainViewController.swift
//  RIR-Display
//
//  Created by Kevin Ramos on 11/28/23.
//

import UIKit
import CoreBluetooth
import Charts

enum RPEScale {
    case BorgRPE
    case BorgCR10
    case Custom
}

protocol OnHeartRateReceivedDelegate: AnyObject {
    func onHeartRateReceived(bpm: Int)
}

class MainViewController: UIViewController, OnHeartRateReceivedDelegate {
    
    @IBOutlet weak var BPMLabel: UILabel!
    @IBOutlet weak var RPELabel: UILabel!
    @IBOutlet weak var RPEDecLabel: UILabel!
    
    @IBOutlet weak var maxField: UITextField!
    @IBOutlet weak var restField: UITextField!
    @IBOutlet weak var KBToolbar: UIToolbar!
    
    @IBOutlet weak var graphView: UIView!
    
    @IBOutlet weak var scaleSegmentedControl: UISegmentedControl!

    @IBOutlet weak var scrollView: UIScrollView!
    

    @IBOutlet weak var dataView: UIView!
    var barChart = BarChartView()
    
    static let MainView = MainViewController.self
    
    static weak var onHeartRateReceivedDelegate: OnHeartRateReceivedDelegate?
    
    var scale: RPEScale = RPEScale.BorgRPE
    
    var bpm: Int = 0
    var restBPM: Int = 60
    var maxBPM: Int = 140
    var customMaxBPM: Int = 200
    
    var ratedPercievedExertion: Float = 0
    
    var hrData: [Int] = []
    var hrMaxLen: Int = 60
    var curGraphIndex: Int = 60
    
    var graphEntries: [BarChartDataEntry] = [BarChartDataEntry]()

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
        
        (restBPM, maxBPM) = hrData.minAndMax() ?? (restBPM, maxBPM)
        
        UpdateRPELabels()
        // Update Labels
        BPMLabel.text = String(bpm)
        if (scale != RPEScale.Custom)  {
            maxField.text = String(maxBPM)
        }
        
        restField.text = String(restBPM)
        
        print("🍏", bpm, "BPM | RPE", ratedPercievedExertion)
        AddHRtoData(bpm: bpm)
    }
    
    private func UpdateRPELabels() {
        // Separate whole value from decimal
        let wholeValue = Int(floor(ratedPercievedExertion))
        let decValue: Float = floor((ratedPercievedExertion - Float(wholeValue)) * 100) / Float(100)
        let decString = String(format: "%.2f", decValue).replacingOccurrences(of: "^\\d*\\.", with: ".", options: .regularExpression)
        
        
        // Update Labels
        RPELabel.text = String(wholeValue)
        RPEDecLabel.text = String(decString)
    }
    
    
    @IBAction func didTapScaleControl(_ sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex) {
        case 0:
            scale = RPEScale.BorgRPE
            maxField.text = String(maxBPM)
        case 1:
            scale = RPEScale.BorgCR10
            maxField.text = String(maxBPM)
        case 2:
            scale = RPEScale.Custom
            maxField.text = String(customMaxBPM)
        default:
            break
        }
        
        calculateRPE()
        UpdateRPELabels()
    }
    
    private func calculateRPE() {
        // based on selected scale, calculate RPE
        switch(scale) {
            case RPEScale.BorgRPE:
                ratedPercievedExertion = -0.998 + (0.0935 * Float(bpm))
                break;
            case RPEScale.BorgCR10:
                let x = -0.998 + (0.0935 * Float(bpm))
                ratedPercievedExertion = 0.0335*x*x - 0.142*x + 0.3372
                break;
            case RPEScale.Custom:
                ratedPercievedExertion = 1 + Float(10.0 / Float(customMaxBPM - 60)) * Float(bpm - 60)
                break
        }
        
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
