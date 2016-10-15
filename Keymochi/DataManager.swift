//
//  DataManager.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/16/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

import Firebase
import FirebaseAnalytics
import FirebaseDatabase
import RealmSwift
import PAM

class DataManager {
    
    static let sharedInatance = DataManager()
    
    let directoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.groupIdentifier)
    let realmPath: String
    
    var _realm: Realm?
    var realm: Realm {
        set {
            _realm = newValue
        }
        get {
            if let _realm = _realm {
                return _realm
            }
            return try! Realm(fileURL: URL(fileURLWithPath: self.realmPath))
        }
    }
    
    init() {
        realmPath = (directoryURL?.appendingPathComponent("db.realm").path)!
        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = URL(fileURLWithPath: realmPath)
        realmConfig.schemaVersion = 5
        realmConfig.migrationBlock = { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: DataChunk.className(), { (oldObject, newObject) in
                    newObject!["appVersion"] = "0.2.0"
                })
            }
            if oldSchemaVersion < 3 {
                migration.enumerateObjects(ofType: DataChunk.className(), { (oldObject, newObject) in
                    newObject!["firebaseKey"] = nil
                })
            }
        }
        Realm.Configuration.defaultConfiguration = realmConfig
    }
    
    fileprivate let realmQueue = DispatchQueue(label: "edu.cornell.tech.Keymochi.datamanager.realmQueue", attributes: [])
    
    // MARK: - Key Events
    fileprivate var _symbolKeyEventSequence: SymbolKeyEventSequence = SymbolKeyEventSequence()
    fileprivate var _backspaceKeyEventSequence: BackspaceKeyEventSequence = BackspaceKeyEventSequence()
    
    func addKeyEvent(_ keyEvent: KeyEvent) {
        realmQueue.async {
            if let symbolKeyEvent = keyEvent as? SymbolKeyEvent {
                self._symbolKeyEventSequence.keyEvents.append(symbolKeyEvent)
            } else if let backspaceKeyEvent = keyEvent as? BackspaceKeyEvent {
                self._backspaceKeyEventSequence.keyEvents.append(backspaceKeyEvent)
            }
        }
    }
    
    // MARK: - Motion Data
    fileprivate var _accelerationDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .acceleration)
    fileprivate var _gyroDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .gyro)
    
    func addMotionDataPoint(_ dataPoint: MotionDataPoint, ofSensorType sensorType: SensorType) {
        
        switch sensorType {
        case .acceleration: _accelerationDataSequence.motionDataPoints.append(dataPoint)
        case .gyro: _gyroDataSequence.motionDataPoints.append(dataPoint)
        }
    }
    
    func dumpCurrentData(withEmotion emotion: Emotion) {
        let totalKeyCount =
            _symbolKeyEventSequence.keyEvents.count + _backspaceKeyEventSequence.keyEvents.count
        
        // Data without legit intertap distance shall not pass.
        if totalKeyCount > 2  {
            print("Dump current data in realm queue")
            print("(\(KeyType.symbol)) \(_symbolKeyEventSequence.keyEvents.count) key events")
            print("(\(KeyType.backspace)) \(_backspaceKeyEventSequence.keyEvents.count) key events")
            print("(\(SensorType.acceleration)) \(_accelerationDataSequence.motionDataPoints.count) data points")
            print("(\(SensorType.gyro)) \(_gyroDataSequence.motionDataPoints.count) data points")
            
            let dataChunck = DataChunk(emotion: emotion)
            dataChunck.symbolKeyEventSequence = _symbolKeyEventSequence
            dataChunck.backspaceKeyEventSequence = _backspaceKeyEventSequence
            dataChunck.accelerationDataSequence = _accelerationDataSequence
            dataChunck.gyroDataSequence = _gyroDataSequence
            
            addDataChunk(dataChunck)
            
            reset()
        }
    }
    
    func reset() {
        _symbolKeyEventSequence = SymbolKeyEventSequence()
        _backspaceKeyEventSequence = BackspaceKeyEventSequence()
        _accelerationDataSequence = MotionDataSequence.init(sensorType: .acceleration)
        _gyroDataSequence = MotionDataSequence.init(sensorType: .gyro)
    }
}

extension DataManager {
    func getDataChunks() -> [DataChunk] {
        return Array(realm.objects(DataChunk.self))
    }
    
    func clearData() {
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
    }
    
    func addDataChunk(_ dataChunck: DataChunk) {
        realm.beginWrite()
        realm.add(dataChunck)
        
        // Add Sequences
        if let symbolKeyEventSequence = dataChunck.symbolKeyEventSequence {
            realm.add(symbolKeyEventSequence)
            for keyEvent in symbolKeyEventSequence.keyEvents {
                realm.add(keyEvent)
            }
        }
        
        if let backspaceKeyEventSequence = dataChunck.backspaceKeyEventSequence {
            realm.add(backspaceKeyEventSequence)
            for keyEvent in backspaceKeyEventSequence.keyEvents {
                realm.add(keyEvent)
            }
        }
        
        if let accelerationDataSequence = dataChunck.accelerationDataSequence {
            realm.add(accelerationDataSequence)
            for dataPoint in accelerationDataSequence.motionDataPoints {
                realm.add(dataPoint)
            }
        }
        
        if let accelerationDataSequence = dataChunck.accelerationDataSequence {
            realm.add(accelerationDataSequence)
            for dataPoint in accelerationDataSequence.motionDataPoints {
                realm.add(dataPoint)
            }
        }
        
        if let gyroDataSequence = dataChunck.gyroDataSequence {
            realm.add(gyroDataSequence)
            for dataPoint in gyroDataSequence.motionDataPoints {
                realm.add(dataPoint)
            }
        }
        
        try! realm.commitWrite()
    }
    
    func upload(dataChunk: DataChunk) {
        guard let sharedDefaults = UserDefaults(suiteName: Constants.groupIdentifier) else { return }
        guard let uid = sharedDefaults.object(forKey: "userid_preference") as? String else { return }
        guard !uid.isEmpty else { return }
        guard var data = dataChunk.dictionaryForm else { return }
        
        data["user"] = uid
        
        var databaseReference: FIRDatabaseReference!
        databaseReference = FIRDatabase.database().reference().child("users").child(uid).childByAutoId()
        
        databaseReference.updateChildValues(data) { (error, refernce) in
            if error == nil {
                try! DataManager.sharedInatance.realm.write { dataChunk.firebaseKey = refernce.url }
            }
        }
    }
    
}
