//
//  Motion.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/16/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

enum SensorType {
    case Accelerametor, Gyro
}

class MotionDataPoint: Object {
    dynamic var x: Double = 0.0
    dynamic var y: Double = 0.0
    dynamic var z: Double = 0.0
    dynamic var time: Double = 0.0
}

class MotionDataSequence: Object {
    
    required init(sensorType: SensorType) {
        self.sensorType = sensorType
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }
    
    let sensorType: SensorType
    let motionDataPoints = List<MotionDataPoint>()
}

class MotionEvent: Object {
    var accelerametorDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .Accelerametor)
    var gyroDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .Gyro)
}