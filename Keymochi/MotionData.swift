//
//  Motion.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/16/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

enum SensorType: CustomStringConvertible, CustomDebugStringConvertible {
    case Acceleration, Gyro
    
    var description: String {
        switch (self) {
        case .Acceleration: return "Acceleration"
        case .Gyro: return "Gyro"
        }
    }
    
    var debugDescription: String {
        return description
    }
}

class MotionDataCollection: Object {
    dynamic var accelerationDataSequence: MotionDataSequence?
    dynamic var gyroDataSequence: MotionDataSequence?
}

class MotionDataSequence: Object {
    
    convenience required init(sensorType: SensorType) {
        self.init()
        self.sensorType = sensorType
    }
    
    var sensorType: SensorType = .Acceleration
    let motionDataPoints = List<MotionDataPoint>()
}

class MotionDataPoint: Object {
    dynamic var x: Double = 0.0
    dynamic var y: Double = 0.0
    dynamic var z: Double = 0.0
    dynamic var time: Double = 0.0
}

