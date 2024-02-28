# RPE-Display
- RPE display is an iOS app that uses Bluetooth Heart Rate Monitors to display the RPE of a performed lift.
- Lines of Code: ~531 lines

# Demo
![](https://github.com/krrgit/RPE-Display/rpedemo.gif)

# Source Code Structure
- MainViewController - this view is the home screen of the app. It displays a heart rate(HR) graph, the HR, the min heartrate within 1 min, and the max.
- BluetoothViewController - This view allows the user to connect to a bluetooth heart rate monitor. It displays all the heart rate devices detected via bluetooth.
- BluetoothManager - This contains the class that manages the bluetooth connection. Referenced in the MainViewController and BluetoothViewController.
- PeripheralCell - This is the cell that represents the found bluetooth devices in BluetoothViewController. Contains the name of the device.
- Main - This is the main storyboard of the app. This is where the layout of the app is contained.

# How to Use
- As bluetooth is not supported in the iOS Simulator, the app needs to be ran on an actual iOS device. 
- Build and run the app on an iOS device. [Running your app in Simulator or on a device.](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- Once the app is on the device:
  - Connecting to the Bluetooth Device
    1. Turn on a Bluetooth compatible Heart Rate monitor and wear it according to the instructions.
    2. Tap the "Connect" button in the top right.
    3. Select the bluetooth device (wait a few seconds for it to connect, it'll show in XCode).
    4. Return to the main screen and see your HR update live.
  - Using the App
    1. For Heavy Compound Lifts
       1. Select Custom in the slider control
       2. Tap the Max HR value and set it to 220 - your age
       3. Workout
       4. See results
    2. For Isolation Lifts
       1. Select Custom in the slider control
       2. Do one set to failure and record your max HR 
       3. Tap the Max HR value and set it to the recorded max HR
       4. Do another set
       5. See sesults
Note: These instructions may become slightly out of date if the app is updated.
