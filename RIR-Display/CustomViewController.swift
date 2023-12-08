//
//  CustomViewController.swift
//  Pods
//
//  Created by Kevin Ramos on 12/7/23.
//

import UIKit

class CustomViewController: UIViewController {
    
    @IBOutlet weak var maxTextField: UITextField!
    
    @IBOutlet weak var yAxisView: UIView!
    
    @IBOutlet weak var KBToolbar: UIToolbar!
    
    
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var slider4: UISlider!
    @IBOutlet weak var slider5: UISlider!
    @IBOutlet weak var slider6: UISlider!
    
    var maxHR: Int = 200
    var yLabels: [UILabel] = []
    var sliders: [UISlider] = []
    
    var hrValues: [Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initYAxis()
        initSliderArray()
        // Do any additional setup after loading the view.
        maxTextField.inputAccessoryView = KBToolbar
    }
    
    private func initSliderArray() {
        sliders.append(slider1)
        sliders.append(slider2)
        sliders.append(slider3)
        sliders.append(slider4)
        sliders.append(slider5)
        sliders.append(slider6)
        
        for slider in sliders {
            hrValues.append(Int(slider.value * Float(maxHR)))
        }
    }
    

    private func initYAxis() {
        let yPos = 65
        let labelCount = 4
        let granularity: Int = Int(Float(maxHR-60) * 0.5) / (labelCount+1)
        var currHR = maxHR - granularity
        
        for i in 0...labelCount {
            let label = UILabel()
            label.text = String(currHR)
            label.frame = CGRect(x:8, y: yPos + (38*i), width: 35, height: 21)
            yLabels.append(label)
            yAxisView.addSubview(label)
            currHR -= granularity
        }
    }
    
    private func updateYAxis() {
        let yPos = 65
        let labelCount = 4
        let granularity: Int = Int(Float(maxHR-60) * 0.5) / (labelCount+1)
        var currHR = maxHR - granularity
        
        for label in yLabels {
            label.text = String(currHR)
            currHR -= granularity
        }
    }
    
    @IBAction func didEndMaxEdit(_ sender: Any) {
        let value = Int(maxTextField.text ?? "200")
        maxHR = max(60, value!)
        updateYAxis()
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        view.endEditing(true)
        resignFirstResponder()
    }
    
    @IBAction func sliderValueChange(_ sender: Any) {
        let changedSlider = sender as! UISlider
        
        if let i = sliders.firstIndex(of: changedSlider){
            hrValues[i] = Int(changedSlider.value * Float(maxHR-60) + 60)
            print("🍏 Updated", i, "slider value,", hrValues[i] )
        }
    }
    
    
    
}

