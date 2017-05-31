//
//  BLEManager.swift
//  RJTPeripheral
//
//  Created by Labs on 5/17/17.
//  Copyright © 2017 Tera Mo Labs. All rights reserved.
//

import CoreBluetooth

enum Services: String {
    case heartMonitor = "CE4CFF01-B85D-49AA-8E03-0D34779A6EEF"
    case stepsMonitor = "3E18B512-D819-4550-8343-F9EFFDA2F896"
    case temperatureMonitor = "4B5CF42E-3224-43B4-AFA2-8A0917B34856"
}

enum Characteristics: String {
    case heartRate = "7821C91E-A551-4907-A5E0-F6CB64AC0A4B"
    case stepsCount = "EE6134CF-F907-45CD-B259-2AB681CA6B32"
    case temperatureStat = "2BCE8CF5-F03E-4EB2-BB35-77C87AC5F1A4"
}

class BLEManager: NSObject {
    
    static let sharedManager = BLEManager()
    
    fileprivate var peripheralManager: CBPeripheralManager?
    
    fileprivate let heartMonitorServiceUUID = CBUUID(string: Services.heartMonitor.rawValue)
    fileprivate let heartRateCharacteristicUUID = CBUUID(string: Characteristics.heartRate.rawValue)
    
    fileprivate let stepsMonitorServiceUUID = CBUUID(string: Services.stepsMonitor.rawValue)
    fileprivate let stepsCountCharacteristicUUID = CBUUID(string: Characteristics.stepsCount.rawValue)
    
    fileprivate let temperatureMonitorServiceUUID = CBUUID(string: Services.temperatureMonitor.rawValue)
    fileprivate let temperatureStatCharacteristicUUID = CBUUID(string: Characteristics.temperatureStat.rawValue)
    
    fileprivate var heartRateCharacteristic: CBMutableCharacteristic?
    fileprivate var heartMonitorService: CBMutableService?
    
    fileprivate var temperatureStatCharacteristic: CBMutableCharacteristic?
    fileprivate var temperatureMonitorService: CBMutableService?
    
    fileprivate var stepsCountCharacteristic: CBMutableCharacteristic?
    fileprivate var stepsMonitorService: CBMutableService?
    
    fileprivate let heartRates = ["60", "70", "80", "90", "100", "120", "140"]
    fileprivate var timer: Timer?
    
    fileprivate let steps = ["25", "36", "42", "50", "66", "79", "82", "95", "104", "118", "245", "331"]
    
    fileprivate let temperatures = ["97", "98", "99", "100", "101"]
    
    private override init() {}
    
    func startUp() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
}

extension BLEManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            heartRateCharacteristic = CBMutableCharacteristic(type: heartRateCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: .readable)
            
            heartMonitorService = CBMutableService(type: heartMonitorServiceUUID, primary: true)
            heartMonitorService?.characteristics = [heartRateCharacteristic!]
            
            peripheralManager?.add(heartMonitorService!)
            
            stepsCountCharacteristic = CBMutableCharacteristic(type: stepsCountCharacteristicUUID, properties: .read, value: nil, permissions: .readable)
            
            stepsMonitorService = CBMutableService(type: stepsMonitorServiceUUID, primary: true)
            stepsMonitorService?.characteristics = [stepsCountCharacteristic!]
            peripheralManager?.add(stepsMonitorService!)
            
            
            temperatureStatCharacteristic = CBMutableCharacteristic(type: temperatureStatCharacteristicUUID, properties: .read, value: nil, permissions: .readable)
            temperatureMonitorService = CBMutableService(type: temperatureMonitorServiceUUID, primary: true)
            temperatureMonitorService?.characteristics = [temperatureStatCharacteristic!]
            
            peripheralManager?.add(temperatureMonitorService!)
            
            peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [heartMonitorServiceUUID, stepsMonitorServiceUUID, temperatureMonitorServiceUUID], CBAdvertisementDataLocalNameKey:"Rebecca's rMBP"])
        }
        else {
            assert(false)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            print("Error: ", error?.localizedDescription ?? "")
        }
        else {
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("Error: ", error?.localizedDescription ?? "")
        }
        else {
            print("Advertising")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic == stepsCountCharacteristic {
            let randomNum = arc4random_uniform(UInt32(self.steps.count))
            if let data = self.steps[Int(randomNum)].data(using: .utf8) {
                request.value = data
                peripheralManager?.respond(to: request, withResult: .success)
            }
        }
        
        if request.characteristic == temperatureStatCharacteristic {
            let randomNum = arc4random_uniform(UInt32(self.temperatures.count))
            if let data = self.temperatures[Int(randomNum)].data(using: .utf8) {
                request.value = data
                peripheralManager?.respond(to: request, withResult: .success)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        if characteristic == heartRateCharacteristic {
            startSendingHeartRate()
        }
    }
    
    func startSendingHeartRate() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (t) in
            let randomNum = arc4random_uniform(UInt32(self.heartRates.count))
            if let data = self.heartRates[Int(randomNum)].data(using: .utf8) {
                self.peripheralManager?.updateValue(data, for: self.heartRateCharacteristic!, onSubscribedCentrals: nil)
            }
        })
        timer?.fire()
    }
}
