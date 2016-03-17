//
//  DataManager.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/16/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager {
    
    static let sharedInatance = DataManager()
    
    let directoryURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.groupIdentifier)
    let realmPath: String
    
    private var _accelerationDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .Acceleration)
    private var _gyroDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .Gyro)
    
    init() {
        realmPath = (directoryURL?.URLByAppendingPathComponent("db.realm").path)!
    }
    
    private let realmQueue = dispatch_queue_create("com.emomeapp.emome.suggestionQueue", DISPATCH_QUEUE_SERIAL)
    
    func saveMotionData(data: (Double, Double, Double), ofSensorType sensorType: SensorType, atTime time: Double) {
        var dataSequence: MotionDataSequence!
        switch sensorType {
        case .Acceleration: dataSequence = _accelerationDataSequence
        case .Gyro: dataSequence = _gyroDataSequence
        }
        
        dispatch_async(realmQueue) {
            print("Create data point in realm queue")
            
            let realm = try! Realm.init(path: self.realmPath)
            realm.beginWrite()
            
            let dataPoint = MotionDataPoint()
            dataPoint.x = data.0
            dataPoint.y = data.1
            dataPoint.z = data.2
            dataPoint.time = time
            dataSequence.motionDataPoints.append(dataPoint)
            print("\(sensorType) has \(dataSequence.motionDataPoints.count) data points.")
            
            try! realm.commitWrite()
        }
    }
    
    func dumpCurrentMotionSequences() {
        dispatch_async(realmQueue) {
            print("Dump current motion sequences in realm queue")
            print("(\(SensorType.Acceleration)) \(self._accelerationDataSequence.motionDataPoints.count) data points")
            print("(\(SensorType.Gyro)) \(self._gyroDataSequence.motionDataPoints.count) data points")
            
            let realm = try! Realm.init(path: self.realmPath)
            realm.beginWrite()
            
            // Add data points
            for dataPoint in self._accelerationDataSequence.motionDataPoints {
                realm.add(dataPoint)
            }
            
            for dataPoint in self._accelerationDataSequence.motionDataPoints {
                realm.add(dataPoint)
            }
            
            // Add sequences
            realm.add(self._accelerationDataSequence)
            realm.add(self._gyroDataSequence)
            
            // Add event
            let motionDataCollection = MotionDataCollection()
            motionDataCollection.accelerationDataSequence = self._accelerationDataSequence
            motionDataCollection.gyroDataSequence = self._gyroDataSequence
            realm.add(motionDataCollection)
            
            try! realm.commitWrite()
            
            self._accelerationDataSequence = MotionDataSequence.init(sensorType: .Acceleration)
            self._gyroDataSequence = MotionDataSequence.init(sensorType: .Gyro)
        }
    }
}